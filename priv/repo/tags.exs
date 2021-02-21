alias ClassicClips.Timeline.{Tag}
alias ClassicClips.Repo

tags = [
  %{name: "JD", code: "jd", type: "crew"},
  %{name: "Skeets", code: "jd", type: "crew"},
  %{name: "Trey", code: "jd", type: "crew"},
  %{name: "Tas", code: "jd", type: "crew"},
  %{name: "Leigh", code: "jd", type: "crew"},
  %{name: "Out of Context", code: "out-of-context", type: "topics"},
  %{name: "Leigh Story", code: "leigh-story", type: "topics"},
  %{name: "Hot Take", code: "hot-take", type: "topics"},
]

taggers = Enum.map(tags, &(Tag.changeset(%Tag{}, &1))) |> IO.inspect

Enum.each(taggers, fn t ->
  IO.inspect t
  Repo.insert(t)
end)
