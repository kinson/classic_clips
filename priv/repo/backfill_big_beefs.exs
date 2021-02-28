alias ClassicClips.BigBeef.BigBeefEvent
alias ClassicClips.Repo

beef = [
  %{
    beef_count: 21,
    date_time: "2021-02-02T12:00:00Z",
    ext_game_id: ""
    player_id: ""
  }
]

big_beef = [
  %{
    beef_id: "005de8e3-9b5b-41c1-94fd-edabf9a423bf",
    yt_highlight_video_url: "https://www.youtube.com/watch?v=T9maCzeQJ-Q&t=123s",
    box_score_url: "https://www.basketball-reference.com/boxscores/202102260BOS.html"
  }
]


bbs = Enum.map(big_beef, &(BigBeefEvent.changeset(%BigBeefEvent{}, &1)))

Enum.each(bbs, fn bb ->
  Repo.insert(bb)
end)
