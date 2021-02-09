# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ClassicClips.Repo.insert!(%ClassicClips.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

titles = [
  "Leigh does something silly",
  "Skeets accidentally says no dinks again",
  "Trey is back, baby",
  "Tas eats a lot roast beer",
  "JD is somehow still awake after 4 podcasts in one day"
]

user = %ClassicClips.Timeline.User{
  username: "mattyo",
  email: "mattyo@gmail.com",
  active: true,
  google_id: "googleid"
}
|> ClassicClips.Repo.insert!(returning: true)

clips = Enum.map(titles, fn title ->
  %{
    yt_video_url: "https://youtu.be/3_U3AwtmVQo?t=1352",
    title: title,
    yt_thumbnail_url: "https://i.ytimg.com/vi/3_U3AwtmVQo/mqdefault.jpg",
    vote_count: 55,
    clip_length: nil,
    user_id: user.id,
    inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
    updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  }
end) |> IO.inspect()

ClassicClips.Repo.insert_all(ClassicClips.Timeline.Clip, clips)
