defmodule ClassicClips.GameData do
  defstruct [:id, :start_time, :status, :away_team_code, :home_team_code, final_fetch_count: 0]

  alias ClassicClips.GameData

  defp game_not_postponed?(%GameData{status: status}), do: status != "PPD"

  defp game_not_final?(%GameData{status: status}), do: status != "Final"

  defp game_started?(%GameData{start_time: start_time}) do
    DateTime.compare(DateTime.utc_now(), start_time) == :gt
  end

  defp final_game_needs_more_data?(%GameData{final_fetch_count: final_fetch_count}) do
    final_fetch_count < 20
  end

  def should_fetch_game_data?(%GameData{} = game_data) do
    game_started?(game_data) and game_not_postponed?(game_data) and
      final_game_needs_more_data?(game_data)
  end

  def should_keep_game_on_active_list?(%GameData{} = game_data) do
    game_not_postponed?(game_data) and final_game_needs_more_data?(game_data)
  end

  def is_game_active?(%GameData{} = game_data) do
    game_started?(game_data) and game_not_postponed?(game_data) and game_not_final?(game_data)
  end

  def increment_fetch_count(
        %GameData{final_fetch_count: final_fetch_count, status: "Final"} = game_data
      ) do
    %GameData{game_data | final_fetch_count: final_fetch_count + 1}
  end

  def increment_fetch_count(%GameData{} = gd), do: gd
end
