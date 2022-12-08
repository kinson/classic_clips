defmodule PickEmWeb.PickEmLive.MatchupHero do
  use PickEmWeb, :live_view
  import PickEmWeb.PickEmLive.Emoji

  alias ClassicClips.PickEm
  alias PickEmWeb.PickEmLive.{Theme, User}
  alias ClassicClips.PickEm.MatchUp
  alias ClassicClips.PickEm.NdcRecord
  alias ClassicClips.BigBeef.Season

  @impl true
  def mount(_params, session, socket) do
    theme = Theme.default_theme()
    ndc_record = PickEm.get_current_ndc_record_cached()

    {:ok,
     socket
     |> assign(:page, "matchup-hero")
     |> assign(:ndc_record, ndc_record)
     |> assign(:theme, theme)}
  end

  @impl true
  def handle_params(%{"matchup_id" => matchup_id}, _, socket) do
    matchup = PickEm.get_matchup_by_id(matchup_id)

    {:noreply, assign(socket, :matchup, matchup)}
  end

  defp render_game_spread(%MatchUp{
         spread: "-" <> spread,
         away_team_id: team_id,
         favorite_team_id: team_id
       }) do
    "(+#{spread})"
  end

  defp render_game_spread(%MatchUp{
         spread: "-" <> spread,
         home_team_id: team_id,
         favorite_team_id: team_id
       }) do
    "(-#{spread})"
  end

  defp render_ndc_pick_image(%MatchUp{away_team_id: team_id, away_team: away_team}, team_id) do
    "/images/#{away_team.abbreviation}_LOGO.png"
  end

  defp render_ndc_pick_image(%MatchUp{home_team_id: team_id, home_team: home_team}, team_id) do
    "/images/#{home_team.abbreviation}_LOGO.png"
  end

  defp get_ndc_record_string(_, nil) do
    "0-0"
  end

  defp get_ndc_record_string(:tas, %NdcRecord{} = ndc_record) do
    "#{ndc_record.tas_wins}-#{ndc_record.tas_losses}"
  end

  defp get_ndc_record_string(:trey, %NdcRecord{} = ndc_record) do
    "#{ndc_record.trey_wins}-#{ndc_record.trey_losses}"
  end

  defp get_ndc_record_string(:skeets, %NdcRecord{} = ndc_record) do
    "#{ndc_record.skeets_wins}-#{ndc_record.skeets_losses}"
  end
end
