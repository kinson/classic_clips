alias ClassicClips.Timeline.{Tag}
alias ClassicClips.Repo

tags = [
  %{name: "JD", code: "jd", type: "crew"},
  %{name: "Skeets", code: "skeets", type: "crew"},
  %{name: "Trey", code: "trey", type: "crew"},
  %{name: "Tas", code: "tas", type: "crew"},
  %{name: "Leigh", code: "leigh", type: "crew"},
  %{name: "Leigh Story", code: "leigh-story", type: "topics"},
  %{name: "Hot Take", code: "hot-take", type: "topics"},
  %{name: "Out of Context", code: "out-of-context", type: "topics"},
  %{name: "Wedgie", code: "wedgie", type: "topics"},
  %{name: "Big Beef", code: "big-beef", type: "topics"},
  %{name: "Prediction", code: "prediction", type: "topics"},
  %{name: "Classic Drop", code: "classic-drop", type: "topics"}
]

tags_beta = [
  %{name: "Ad Read", code: "ad-read", type: "topics"},
  %{name: "Top 5", code: "top-five", type: "topics"},
  %{name: "Rapid Fire", code: "rapid-fire", type: "topics"},
  %{name: "Tweet Of The Night", code: "tofn", type: "topics"}
]

taggers = Enum.map(tags_beta, &(Tag.changeset(%Tag{}, &1)))

Enum.each(taggers, fn t ->
  Repo.insert(t)
end)
