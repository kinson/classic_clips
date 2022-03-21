defmodule ClassicClips.PickEm do
  import Ecto.Query, warn: false

  require Logger

  use NewRelic.Tracer

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.{MatchUp, UserPick, NdcPick, UserRecord, Team, NdcRecord}
  alias ClassicClips.Timeline.User

  @new_york_offset 4 * 60 * 60

  @trace :get_cached_current_matchup
  def get_cached_current_matchup() do
    case Fiat.CacheServer.fetch_object(:current_matchup) do
      nil ->
        current_matchup = get_current_matchup()
        Fiat.CacheServer.cache_object(:current_matchup, current_matchup, 60)
        NewRelic.increment_custom_metric("Custom/CurrentMatchupCache/Miss")
        current_matchup

      current_matchup ->
        NewRelic.increment_custom_metric("Custom/CurrentMatchupCache/Hit")
        current_matchup
    end
  end

  @trace :set_cached_current_matchup
  def set_cached_current_matchup() do
    current_matchup = get_current_matchup()
    Fiat.CacheServer.cache_object(:current_matchup, current_matchup, 60)
    current_matchup
  end

  @trace :get_current_matchup
  def get_current_matchup() do
    from(m in MatchUp,
      order_by: [desc: m.tip_datetime],
      limit: 1
    )
    |> Repo.one()
    |> Repo.preload([:home_team, :away_team, :favorite_team, :winning_team])
  end

  def get_todays_matchup() do
    matchup = get_current_matchup()

    if is_game_today?(matchup) do
      matchup
    else
      nil
    end
  end

  def is_game_today?(%MatchUp{} = matchup) do
    tip_date =
      matchup
      |> Map.get(:tip_datetime)
      |> DateTime.add(-1 * get_est_offset_seconds())
      |> DateTime.to_date()

    current_date = DateTime.utc_now() |> DateTime.add(-1 * get_est_offset_seconds())

    case Date.compare(current_date, tip_date) do
      :eq -> true
      _ -> false
    end
  end

  def is_game_today?(%{game_time_utc: game_time_utc}) do
    tip_date =
      game_time_utc
      |> DateTime.add(-1 * get_est_offset_seconds())
      |> DateTime.to_date()

    current_date = DateTime.utc_now() |> DateTime.add(-1 * get_est_offset_seconds())

    case Date.compare(current_date, tip_date) do
      :eq -> true
      _ -> false
    end
  end

  @trace :get_cached_ndc_pick_for_matchup
  def get_cached_ndc_pick_for_matchup(%MatchUp{id: id} = matchup) do
    Fiat.CacheServer.fetch_object(
      {:ndc_pick, id},
      fn -> get_ndc_pick_for_matchup(matchup) end,
      60
    )
  end

  @trace :get_ndc_pick_for_matchup
  def get_ndc_pick_for_matchup(%MatchUp{id: id}) do
    Repo.get_by(NdcPick, matchup_id: id)
    |> Repo.preload([:skeets_pick_team, :leigh_pick_team, :tas_pick_team, :trey_pick_team])
  end

  @trace :get_current_ndc_record
  def get_current_ndc_record() do
    Repo.get_by(NdcRecord, month: get_current_month_name())
  end

  @trace :get_users_pick_for_matchup
  def get_user_pick_for_matchup(nil, _), do: nil

  @trace :get_user_pick_for_matchup
  def get_user_pick_for_matchup(%User{id: user_id}, %MatchUp{id: matchup_id}) do
    Repo.get_by(UserPick, matchup_id: matchup_id, user_id: user_id)
    |> Repo.preload([:picked_team])
  end

  @trace :save_user_pick
  def save_user_pick(nil, selected_team, %User{id: user_id}, %MatchUp{id: matchup_id}) do
    UserPick.changeset(%UserPick{}, %{
      user_id: user_id,
      matchup_id: matchup_id,
      picked_team_id: selected_team.id
    })
    |> Repo.insert()
  end

  @trace :save_user_pick
  def save_user_pick(%UserPick{} = user_pick, selected_team, %User{id: user_id}, _)
      when user_pick.user_id == user_id do
    UserPick.changeset(user_pick, %{picked_team_id: selected_team.id})
    |> Repo.update()
  end

  def remove_user_picks_for_matchup(%MatchUp{id: id}) do
    from(up in UserPick, where: up.matchup_id == ^id) |> Repo.delete_all()
  end

  @trace :get_cached_pick_spread
  def get_cached_pick_spread(matchup) do
    Fiat.CacheServer.fetch_object(
      {:matchup_pick_spread, matchup.id},
      fn ->
        get_pick_spread(matchup)
      end,
      30
    )
  end

  @trace :get_pick_spread
  def get_pick_spread(%MatchUp{id: id}) do
    from(up in UserPick, select: up.picked_team_id, where: up.matchup_id == ^id)
    |> Repo.all()
    |> Enum.frequencies()
  end

  @trace :get_leaders_cached
  def get_leaders_cached do
    Fiat.CacheServer.fetch_object(:leaders, &get_leaders/0, 180)
  end

  @trace :get_leaders
  def get_leaders do
    current_month = get_current_month_name()

    subquery =
      from(up in UserPick,
        left_join: m in assoc(up, :matchup),
        where: m.month == ^current_month,
        group_by: up.user_id,
        select: %{user_id: up.user_id, total_picks: count(up.id)}
      )

    from(ur in UserRecord,
      join: up in subquery(subquery),
      on: up.user_id == ur.user_id,
      join: u in assoc(ur, :user),
      where: ur.month == ^current_month,
      order_by: [desc: ur.wins, desc: up.total_picks, desc: ur.id],
      preload: [user: u],
      limit: 100,
      select: {up, ur}
    )
    |> Repo.all()
    |> Enum.map(fn {up, ur} ->
      %{
        user: ur.user,
        wins: ur.wins,
        losses: ur.losses,
        total_picks: up.total_picks
      }
    end)
  end

  @trace :update_user_picks_with_matchup_result
  def update_user_picks_with_matchup_result(game_data, matchup) do
    user_picks =
      from(up in UserPick, where: up.matchup_id == ^matchup.id)
      |> Repo.all()
      |> Repo.preload([:picked_team])

    game_winning_team_id = get_game_winning_team_id(game_data, matchup)
    spread_winning_team_id = get_spread_winning_team_id(game_data, matchup)

    update_matchup_with_winner(matchup, game_winning_team_id, game_data)

    user_picks
    |> Enum.map(fn pick ->
      case pick.picked_team.id do
        ^spread_winning_team_id -> UserPick.changeset(pick, %{result: :win})
        _ -> UserPick.changeset(pick, %{result: :loss})
      end
    end)
    |> Enum.map(&Repo.update/1)

    season = Repo.get_by!(ClassicClips.BigBeef.Season, current: true)

    user_picks
    |> Enum.map(fn pick ->
      if pick.picked_team_id == spread_winning_team_id do
        create_or_update_user_record(pick.user_id, season.id, 1, 0)
      else
        create_or_update_user_record(pick.user_id, season.id, 0, 1)
      end
    end)

    Logger.notice("Updated #{Enum.count(user_picks)} user picks")
  end

  @trace :update_ndc_records_with_matchup_result
  def update_ndc_records_with_matchup_result(game_data, matchup) do
    spread_winning_team_id = get_spread_winning_team_id(game_data, matchup)
    current_month = get_current_month_name()
    ndc_pick = get_ndc_pick_for_matchup(matchup)

    ndc_record = Repo.get_by(ClassicClips.PickEm.NdcRecord, month: current_month)

    case ndc_record do
      nil -> create_ndc_record_for_month(current_month, spread_winning_team_id, ndc_pick)
      record -> update_ndc_record(record, spread_winning_team_id, ndc_pick)
    end
  end

  @trace :create_ndc_record_for_month
  defp create_ndc_record_for_month(current_month, spread_winning_team_id, %NdcPick{} = ndc_pick) do
    ndc_record = %NdcRecord{
      month: current_month,
      tas_losses: 0,
      tas_wins: 0,
      trey_losses: 0,
      trey_wins: 0,
      skeets_losses: 0,
      skeets_wins: 0,
      leigh_losses: 0,
      leigh_wins: 0
    }

    attrs = increment_ndc_record_counts(ndc_record, spread_winning_team_id, ndc_pick)

    NdcRecord.changeset(ndc_record, attrs)
    |> Repo.insert()
  end

  @trace :update_ndc_record
  defp update_ndc_record(%NdcRecord{} = ndc_record, spread_winning_team_id, %NdcPick{} = ndc_pick) do
    attrs =
      ndc_record
      |> increment_ndc_record_counts(spread_winning_team_id, ndc_pick)

    ndc_record
    |> NdcRecord.changeset(attrs)
    |> Repo.update()
  end

  @trace :increment_ndc_record_counts
  defp increment_ndc_record_counts(
         %NdcRecord{} = ndc_record,
         spread_winning_team_id,
         %NdcPick{} = ndc_pick
       ) do
    %{}
    |> Map.put(
      :leigh_losses,
      get_ndc_record_attribute(
        :losses,
        ndc_record.leigh_losses,
        ndc_pick.leigh_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :skeets_losses,
      get_ndc_record_attribute(
        :losses,
        ndc_record.skeets_losses,
        ndc_pick.skeets_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :trey_losses,
      get_ndc_record_attribute(
        :losses,
        ndc_record.trey_losses,
        ndc_pick.trey_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :tas_losses,
      get_ndc_record_attribute(
        :losses,
        ndc_record.tas_losses,
        ndc_pick.tas_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :leigh_wins,
      get_ndc_record_attribute(
        :wins,
        ndc_record.leigh_wins,
        ndc_pick.leigh_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :skeets_wins,
      get_ndc_record_attribute(
        :wins,
        ndc_record.skeets_wins,
        ndc_pick.skeets_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :tas_wins,
      get_ndc_record_attribute(
        :wins,
        ndc_record.tas_wins,
        ndc_pick.tas_pick_team_id,
        spread_winning_team_id
      )
    )
    |> Map.put(
      :trey_wins,
      get_ndc_record_attribute(
        :wins,
        ndc_record.trey_wins,
        ndc_pick.trey_pick_team_id,
        spread_winning_team_id
      )
    )
  end

  defp get_ndc_record_attribute(:wins, current_record, picked_team_id, spread_winning_team_id)
       when picked_team_id == spread_winning_team_id,
       do: current_record + 1

  defp get_ndc_record_attribute(:wins, current_record, _, _), do: current_record

  defp get_ndc_record_attribute(:losses, current_record, picked_team_id, spread_winning_team_id)
       when picked_team_id == spread_winning_team_id,
       do: current_record

  defp get_ndc_record_attribute(:losses, current_record, _, _), do: current_record + 1

  def get_game_winning_team_id(
        %{away: %{score: away_team_score}, home: %{score: home_team_score}},
        %{
          home_team_id: home_team_id,
          away_team_id: away_team_id
        }
      ) do
    if away_team_score > home_team_score do
      away_team_id
    else
      home_team_id
    end
  end

  defp get_spread_winning_team_id(
         %{away: %{score: away_team_score}, home: %{score: home_team_score}},
         %{
           home_team_id: home_team_id,
           away_team_id: away_team_id,
           spread: spread,
           favorite_team_id: favorite_team_id
         }
       )
       when home_team_id == favorite_team_id do
    case spread_winner(home_team_score, away_team_score, spread) do
      :favorite_team -> home_team_id
      :other_team -> away_team_id
    end
  end

  defp get_spread_winning_team_id(
         %{away: %{score: away_team_score}, home: %{score: home_team_score}},
         %{
           home_team_id: home_team_id,
           away_team_id: away_team_id,
           spread: spread,
           favorite_team_id: favorite_team_id
         }
       )
       when away_team_id == favorite_team_id do
    case spread_winner(away_team_score, home_team_score, spread) do
      :favorite_team -> away_team_id
      :other_team -> home_team_id
    end
  end

  def spread_winner(favorite_team_score, other_team_score, spread_string) do
    spread =
      spread_string
      |> String.replace("-", "")
      |> String.to_float()

    if favorite_team_score - other_team_score > spread do
      :favorite_team
    else
      :other_team
    end
  end

  defp update_matchup_with_winner(matchup, winning_team_id, %{
         away: %{score: away_team_score},
         home: %{score: home_team_score}
       }) do
    game_score = "#{away_team_score} - #{home_team_score}"

    MatchUp.changeset(matchup, %{winning_team_id: winning_team_id, score: game_score})
    |> Repo.update()
  end

  defp create_or_update_user_record(user_id, season_id, win_increment, loss_increment) do
    current_month = get_current_month_name()

    case Repo.get_by(UserRecord, user_id: user_id, month: current_month) do
      nil ->
        UserRecord.changeset(%UserRecord{}, %{
          wins: 0 + win_increment,
          losses: 0 + loss_increment,
          user_id: user_id,
          month: current_month,
          season_id: season_id
        })
        |> Repo.insert()

      user_record ->
        UserRecord.changeset(user_record, %{
          wins: user_record.wins + win_increment,
          losses: user_record.losses + loss_increment
        })
        |> Repo.update()
    end
  end

  @trace :get_cached_teams_for_conference
  def get_cached_teams_for_conference(conference) do
    case Fiat.CacheServer.fetch_object({:conference_teams, conference}) do
      nil ->
        NewRelic.increment_custom_metric(
          "Custom/ConferenceTeams-#{Atom.to_string(conference)}-Cache/Miss"
        )

        teams = get_teams_for_conference(conference)
        Fiat.CacheServer.cache_object({:conference_teams, conference}, teams, 600)
        teams

      teams ->
        NewRelic.increment_custom_metric(
          "Custom/ConferenceTeams-#{Atom.to_string(conference)}-Cache/Hit"
        )

        teams
    end
  end

  def get_teams_for_conference(conference) do
    from(t in Team, where: t.conference == ^conference, order_by: [asc: t.location]) |> Repo.all()
  end

  def get_custom_team_emojis(emojis, teams) do
    emoji_teams_by_id =
      Enum.reduce(teams, %{}, fn %Team{id: id} = team, acc ->
        Map.put(acc, id, team.default_emoji)
      end)

    Enum.filter(emojis, fn {id, emoji} ->
      Map.fetch!(emoji_teams_by_id, id) != emoji
    end)
    |> Enum.into(%{})
  end

  @trace :get_picks_for_user_cached
  def get_picks_for_user_cached(user) do
    Fiat.CacheServer.fetch_object(
      {:picks_for_user, user.id},
      fn -> get_picks_for_user(user) end,
      300
    )
  end

  @trace :get_picks_for_user
  def get_picks_for_user(%User{id: user_id}) do
    from(up in UserPick,
      where: up.user_id == ^user_id,
      order_by: [desc: up.inserted_at],
      limit: 30
    )
    |> Repo.all()
    |> Repo.preload([
      :picked_team,
      matchup: [:away_team, :home_team, :favorite_team, :winning_team]
    ])
    |> Enum.sort(fn pick_one, pick_two ->
      DateTime.compare(pick_one.matchup.tip_datetime, pick_two.matchup.tip_datetime) != :lt
    end)
  end

  def get_current_month_name do
    DateTime.utc_now()
    |> DateTime.add(-1 * get_est_offset_seconds())
    |> Map.get(:month)
    |> get_month_name()
  end

  def get_month_name(1), do: "january"
  def get_month_name(2), do: "february"
  def get_month_name(3), do: "march"
  def get_month_name(4), do: "april"
  def get_month_name(5), do: "may"
  def get_month_name(6), do: "june"
  def get_month_name(7), do: "july"
  def get_month_name(8), do: "august"
  def get_month_name(9), do: "september"
  def get_month_name(10), do: "october"
  def get_month_name(11), do: "november"
  def get_month_name(12), do: "december"

  def get_est_offset_seconds do
    @new_york_offset
  end

  @trace :create_matchup
  def create_matchup(
        away_abbreviation,
        home_abbreviation,
        favorite_abbreviation,
        spread,
        game_id,
        game_tip_time,
        leigh_pick_team,
        skeets_pick_team,
        tas_pick_team,
        trey_pick_team
      ) do
    # get away team
    away_team = Repo.get_by!(Team, abbreviation: away_abbreviation)
    # get home team
    home_team = Repo.get_by!(Team, abbreviation: home_abbreviation)
    # get favorite team
    favorite_team = Repo.get_by!(Team, abbreviation: favorite_abbreviation)

    {:ok, tip_datetime_utc, _} = DateTime.from_iso8601(game_tip_time)
    tip_datetime_est = DateTime.add(tip_datetime_utc, -1 * get_est_offset_seconds())

    month = get_month_name(tip_datetime_est.month)

    matchup_changeset =
      MatchUp.changeset(%MatchUp{}, %{
        month: month,
        spread: spread,
        tip_datetime: tip_datetime_utc,
        nba_game_id: game_id,
        away_team_id: away_team.id,
        home_team_id: home_team.id,
        favorite_team_id: favorite_team.id
      })

    ndc_attrs = %{
      skeets_pick_team_id: get_ndc_team_id(away_team, home_team, skeets_pick_team),
      tas_pick_team_id: get_ndc_team_id(away_team, home_team, tas_pick_team),
      trey_pick_team_id: get_ndc_team_id(away_team, home_team, trey_pick_team),
      leigh_pick_team_id: get_ndc_team_id(away_team, home_team, leigh_pick_team)
    }

    with {:ok, matchup} <-
           Repo.insert(matchup_changeset, returning: true),
         matchup <-
           Repo.preload(matchup, [:away_team, :home_team, :favorite_team]),
         ndc_attrs <- Map.put(ndc_attrs, :matchup_id, matchup.id),
         ndc_pick_changeset <- NdcPick.changeset(%NdcPick{}, ndc_attrs),
         {:ok, _} <- Repo.insert(ndc_pick_changeset),
         {:ok, _} <- notify_sickos(matchup),
         {:ok, _} <- post_matchup_on_twitter(matchup) do
      set_cached_current_matchup()
      {:ok, matchup}
    end
  end

  @trace :notify_sickos
  def notify_sickos(matchup) do
    NewRelic.Instrumented.Task.start_link(fn ->
      from(u in User,
        where: u.email_new_matchups == true
      )
      |> Repo.all()
      |> Enum.map(&%{name: &1.username, email: &1.email, matchup: matchup})
      |> Enum.each(&ClassicClips.Timeline.UserNotifier.deliver_new_matchup/1)
    end)

    {:ok, true}
  end

  defp post_matchup_on_twitter(matchup) do
    NewRelic.Instrumented.Task.start_link(fn ->
      %{away_team: away, home_team: home, favorite_team: favorite} = matchup

      away_string = "#{away.location} #{away.name}"
      home_string = "#{home.location} #{home.name}"
      favorite_string = "#{favorite.abbreviation} #{matchup.spread}"

      est_time =
        matchup.tip_datetime
        |> DateTime.add(-1 * get_est_offset_seconds())
        |> DateTime.to_time()
        |> Timex.format!("{h12}:{0m} {AM}")

      tweet_string = """
      Today's matchup is live!
      #{away_string} @ #{home_string} (#{favorite_string})
      Make your pick before #{est_time} EST!
      https://nodunkspickem.com
      """

      ClassicClips.Twitter.post_tweet(tweet_string)
    end)

    {:ok, true}
  end

  defp get_ndc_team_id(%Team{abbreviation: away_team_abbrev} = away_team, _, away_team_abbrev),
    do: away_team.id

  defp get_ndc_team_id(_, %Team{abbreviation: home_team_abbrev} = home_team, home_team_abbrev),
    do: home_team.id

  @trace :forfeit_missed_games
  def forfeit_missed_games(%User{id: user_id} = user) do
    current_month = get_current_month_name()

    user_picks =
      from(up in UserPick,
        where: up.user_id == ^user_id,
        select: up.matchup_id,
        order_by: [desc: up.inserted_at],
        limit: 25
      )

    new_picks =
      from(m in MatchUp,
        where: m.month == ^current_month,
        where: m.id not in subquery(user_picks),
        where: not is_nil(m.winning_team_id),
        select: {m.id, m.winning_team_id, m.away_team_id, m.home_team_id}
      )
      |> Repo.all()
      |> Enum.map(fn
        {matchup_id, winning_team_id, away_team_id, _} when winning_team_id != away_team_id ->
          UserPick.changeset(%UserPick{}, %{
            matchup_id: matchup_id,
            picked_team_id: away_team_id,
            user_id: user_id,
            result: :loss,
            forfeited_at: DateTime.utc_now()
          })
          |> Repo.insert()

        {matchup_id, winning_team_id, _, home_team_id} when winning_team_id != home_team_id ->
          UserPick.changeset(%UserPick{}, %{
            matchup_id: matchup_id,
            picked_team_id: home_team_id,
            user_id: user_id,
            result: :loss,
            forfeited_at: DateTime.utc_now()
          })
          |> Repo.insert()
      end)

    season = Repo.get_by!(ClassicClips.BigBeef.Season, current: true)

    create_or_update_user_record(user_id, season.id, 0, Enum.count(new_picks))

    Fiat.CacheServer.cache_object({:is_missing_picks?, user_id}, false, 1)
    Fiat.CacheServer.cache_object({:picks_for_user, user_id}, get_picks_for_user(user), 10)
  end

  def is_missing_picks_cached?(user) do
    Fiat.CacheServer.fetch_object(
      {:is_missing_picks?, user.id},
      fn -> is_missing_picks?(user) end,
      300
    )
  end

  @trace :is_missing_picks?
  def is_missing_picks?(%User{id: user_id}) do
    current_month = get_current_month_name()

    user_pick_query =
      from(up in UserPick,
        where: up.user_id == ^user_id,
        select: up.matchup_id,
        order_by: [desc: up.inserted_at],
        limit: 25
      )

    missing_matchups =
      from(m in MatchUp,
        where: m.month == ^current_month,
        where: m.id not in subquery(user_pick_query),
        where: not is_nil(m.winning_team_id)
      )
      |> Repo.all()

    case missing_matchups do
      [] -> false
      _ -> true
    end
  end

  def enable_matchup_email_notifications(user),
    do: update_matchup_email_notifications(user, true)

  def disable_matchup_email_notifications(user),
    do: update_matchup_email_notifications(user, false)

  @trace :update_matchup_email_notifications
  def update_matchup_email_notifications(%User{} = user, enabled?) do
    User.changeset(user, %{email_new_matchups: enabled?})
    |> Repo.update(returning: true)
  end

  def get_cached_team_for_abbreviation(abbreviation) do
    Fiat.CacheServer.fetch_object(
      {:team, abbreviation},
      fn -> Repo.get_by!(Team, abbreviation: abbreviation) end,
      3600
    )
  end
end
