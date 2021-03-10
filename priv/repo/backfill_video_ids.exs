alias ClassicClips.{Classics, Repo}
alias ClassicClips.Timeline.Clip
alias ClassicClips.Classics.Video
import Ecto.Query

clips =
  from(c in Clip, select: c)
  |> Repo.all()
  |> Enum.map(fn clip ->
    ext_video_id =
      String.replace(clip.yt_video_url, "https://youtu.be/", "")
      |> String.replace(~r/\?t=.*/, "")

    case Repo.get_by(Video, yt_video_id: ext_video_id) do
      nil -> Clip.changeset(clip, %{})
      %Video{id: id} -> Clip.changeset(clip, %{video_id: id})
    end
  end)

Repo.transaction(fn ->
  Enum.each(clips, &Repo.update!/1)
end)
