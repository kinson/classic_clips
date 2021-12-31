defmodule Mix.Tasks.LoadTeams do
  @moduledoc """
  Load teams into the database if they are not already present.
  """

  use Mix.Task

  import Ecto.Query

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    alias ClassicClips.PickEm.Team
    alias ClassicClips.Repo

    teams = east_team_data() ++ west_team_data()

    Enum.each(teams, fn team ->
      existing_team = Repo.get_by(Team, abbreviation: team.abbreviation)

      case existing_team do
        nil -> Team.changeset(%Team{}, team) |> Repo.insert!()
        existing -> Team.changeset(existing, team) |> Repo.update!()
      end
    end)

    team_count = from(t in Team, select: count(t.id)) |> Repo.one()

    case team_count do
      30 -> IO.puts("Teams updated successfully")
      num -> IO.puts("Unexpected number of teams present: #{num}")
    end
  end

  def east_team_data do
    [
      %{
        name: "Hawks",
        location: "Atlanta",
        abbreviation: "ATL",
        conference: :east,
        default_emoji: "🦅"
      },
      %{
        name: "Celtics",
        location: "Boston",
        abbreviation: "BOS",
        conference: :east,
        default_emoji: "🍀"
      },
      %{
        name: "Nets",
        location: "Brooklyn",
        abbreviation: "BKN",
        conference: :east,
        default_emoji: "🚇"
      },
      %{
        name: "Hornets",
        location: "Charlotte",
        abbreviation: "CHA",
        conference: :east,
        default_emoji: "🐝"
      },
      %{
        name: "Bulls",
        location: "Chicago",
        abbreviation: "CHI",
        conference: :east,
        default_emoji: "🐂"
      },
      %{
        name: "Cavaliers",
        location: "Cleveland",
        abbreviation: "CLE",
        conference: :east,
        default_emoji: "🤺"
      },
      %{
        name: "Pistons",
        location: "Detroit",
        abbreviation: "DET",
        conference: :east,
        default_emoji: "🚗"
      },
      %{
        name: "Pacers",
        location: "Indiana",
        abbreviation: "IND",
        conference: :east,
        default_emoji: "👟"
      },
      %{
        name: "Heat",
        location: "Miami",
        abbreviation: "MIA",
        conference: :east,
        default_emoji: "♨️"
      },
      %{
        name: "Bucks",
        location: "Milwaukee",
        abbreviation: "MIL",
        conference: :east,
        default_emoji: "🦌"
      },
      %{
        name: "Knicks",
        location: "New York",
        abbreviation: "NYK",
        conference: :east,
        default_emoji: "🗽"
      },
      %{
        name: "Magic",
        location: "Orlando",
        abbreviation: "ORL",
        conference: :east,
        default_emoji: "🪄"
      },
      %{
        name: "76ers",
        location: "Philadelphia",
        abbreviation: "PHI",
        conference: :east,
        default_emoji: "🔔"
      },
      %{
        name: "Raptors",
        location: "Toronto",
        abbreviation: "TOR",
        conference: :east,
        default_emoji: "🦖"
      },
      %{
        name: "Wizards",
        location: "Washington",
        abbreviation: "WAS",
        conference: :east,
        default_emoji: "🧙"
      }
    ]
  end

  def west_team_data do
    [
      %{
        name: "Mavericks",
        location: "Dallas",
        abbreviation: "DAL",
        conference: :west,
        default_emoji: "🎖"
      },
      %{
        name: "Nuggets",
        location: "Denver",
        abbreviation: "DEN",
        conference: :west,
        default_emoji: "⛏"
      },
      %{
        name: "Warriors",
        location: "Golden State",
        abbreviation: "GSW",
        conference: :west,
        default_emoji: "⚔️"
      },
      %{
        name: "Rockets",
        location: "Houston",
        abbreviation: "HOU",
        conference: :west,
        default_emoji: "🚀"
      },
      %{
        name: "Clippers",
        location: "Los Angeles",
        abbreviation: "LAC",
        conference: :west,
        default_emoji: "⛵️"
      },
      %{
        name: "Lakers",
        location: "Los Angeles",
        abbreviation: "LAL",
        conference: :west,
        default_emoji: "💦"
      },
      %{
        name: "Grizzlies",
        location: "Memphis",
        abbreviation: "MEM",
        conference: :west,
        default_emoji: "🐻"
      },
      %{
        name: "Timberwolves",
        location: "Minnesota",
        abbreviation: "MIN",
        conference: :west,
        default_emoji: "🐺"
      },
      %{
        name: "Pelicans",
        location: "New Orleans",
        abbreviation: "NOP",
        conference: :west,
        default_emoji: "🦩"
      },
      %{
        name: "Thunder",
        location: "Oklahoma City",
        abbreviation: "OKC",
        conference: :west,
        default_emoji: "⛈"
      },
      %{
        name: "Suns",
        location: "Phoenix",
        abbreviation: "PHX",
        conference: :west,
        default_emoji: "☀️"
      },
      %{
        name: "Trail Blazers",
        location: "Portland",
        abbreviation: "POR",
        conference: :west,
        default_emoji: "🧭"
      },
      %{
        name: "Kings",
        location: "Sacramento",
        abbreviation: "SAC",
        conference: :west,
        default_emoji: "👑"
      },
      %{
        name: "Spurs",
        location: "San Antonio",
        abbreviation: "SAS",
        conference: :west,
        default_emoji: "🤠"
      },
      %{
        name: "Jazz",
        location: "Utah",
        abbreviation: "UTA",
        conference: :west,
        default_emoji: "🎷"
      }
    ]
  end
end
