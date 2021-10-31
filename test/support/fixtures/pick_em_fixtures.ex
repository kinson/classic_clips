defmodule ClassicClips.PickEmFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClassicClips.PickEm` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        abbreviation: "some abbreviation",
        location: "some location",
        name: "some name"
      })
      |> ClassicClips.PickEm.create_team()

    team
  end

  @doc """
  Generate a match_up.
  """
  def match_up_fixture(attrs \\ %{}) do
    {:ok, match_up} =
      attrs
      |> Enum.into(%{
        date: ~D[2021-10-30],
        month: "some month",
        score: "some score",
        spread: "some spread",
        tip_time: ~T[14:00:00]
      })
      |> ClassicClips.PickEm.create_match_up()

    match_up
  end

  @doc """
  Generate a user_pick.
  """
  def user_pick_fixture(attrs \\ %{}) do
    {:ok, user_pick} =
      attrs
      |> Enum.into(%{
        result: "some result"
      })
      |> ClassicClips.PickEm.create_user_pick()

    user_pick
  end

  @doc """
  Generate a ndc_pick.
  """
  def ndc_pick_fixture(attrs \\ %{}) do
    {:ok, ndc_pick} =
      attrs
      |> Enum.into(%{

      })
      |> ClassicClips.PickEm.create_ndc_pick()

    ndc_pick
  end
end
