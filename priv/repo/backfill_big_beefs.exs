alias ClassicClips.BigBeef.{Beef, BigBeefEvent}
alias ClassicClips.BigBeef.Services.Stats
alias ClassicClips.Repo
alias ClassicClips.{GameData, BigBeef}

import Ecto.Query

box_scores = [
  %{
    id: "0022000135",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101090IND.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=JRQDtafvavk"
  },
  %{
    id: "0022000137",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101090MIL.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=JRQDtafvavk"
  },
  %{
    id: "0022000311",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101310MIN.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=dH_HrSKSoVY"
  },
  %{
    id: "0022000293",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101290NOP.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=dH_HrSKSoVY"
  },
  %{
    id: "0022000219",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101200ATL.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=Vau7kyM8BRw"
  },
  %{
    id: "0022000181",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101150CLE.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=_7wM1_Cco-g"
  },
  %{
    id: "0022000248",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101230PHO.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=2YsEOXyxxvo"
  },
  %{
    id: "0022000267",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101250POR.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=6lFyhpUvJDE"
  },
  %{
    id: "0022000369",
    box_score_url: "https://www.basketball-reference.com/boxscores/202102080MEM.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=IhO10YLNH1Y"
  },
  %{
    id: "0022000282",
    box_score_url: "https://www.basketball-reference.com/boxscores/202101270UTA.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=wJy29TmegEg"
  },
  %{
    id: "0022000444",
    box_score_url: "https://www.basketball-reference.com/boxscores/202102170LAC.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=adFrHMCjEpQ"
  },
  %{
    id: "0022000432",
    box_score_url: "https://www.basketball-reference.com/boxscores/202102160OKC.html",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=hYCwJiwVm8s"
  }
]

box_scores_2 = [
  %{
    id: "0022000566",
    box_score_url: "https://www.basketball-reference.com/boxscores/202103100MEM.html",
    yt_highlight_video_url: "aaa"
  }
]

scores =
  box_scores_2
  |> Enum.map(fn %{id: id} -> %GameData{id: id} end)
  |> Enum.map(&BigBeef.get_game_data/1)
  |> Enum.map(fn game ->
    %{
      home: home,
      away: away,
      game_status: game_status,
      game_time: game_time,
      game_start_time: game_start_time,
      game_id: game_id
    } = Stats.extract_team_stats(game)

    Enum.concat(Stats.extract_player_stats(home), Stats.extract_player_stats(away))
    |> Enum.map(&BigBeef.get_or_create_player(&1, game_time, game_id, game_start_time))
  end)
  |> IO.inspect()

big_beefs =
  box_scores_2
  |> Enum.map(fn big ->
    beef =
      from(b in Beef, where: b.ext_game_id == ^big.id, where: b.beef_count > 19) |> Repo.one()

    big_beef =
      BigBeef.create_big_beef_event(%{
        box_score_url: big.box_score_url,
        yt_highlight_video_url: big.yt_highlight_video_url,
        beef_id: beef.id
      })
  end)
  |> IO.inspect()
