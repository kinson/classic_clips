alias ClassicClips.Timeline.{Tag}
alias ClassicClips.Repo

tags = [
  %{name: "JD", code: "jd", type: "crew"},
  %{name: "Skeets", code: "jd", type: "crew"},
  %{name: "Trey", code: "jd", type: "crew"},
  %{name: "Tas", code: "jd", type: "crew"},
  %{name: "Leigh", code: "jd", type: "crew"},
  %{name: "Leigh Story", code: "leigh-story", type: "topics"},
  %{name: "Hot Take", code: "hot-take", type: "topics"},
  %{name: "Out of Context", code: "out-of-context", type: "topics"},
  %{name: "Wedgie", code: "wedgie", type: "topics"},
  %{name: "Wedgie", code: "wedgie", type: "topics"},
  %{name: "Big Beef", code: "big-beef", type: "topics"},
  %{name: "Prediction", code: "prediction", type: "topics"},
  %{name: "Classic Drop", code: "classic-drop", type: "topics"}
]

taggers = Enum.map(tags, &(Tag.changeset(%Tag{}, &1)))

Enum.each(taggers, fn t ->
  Repo.insert(t)
end)
