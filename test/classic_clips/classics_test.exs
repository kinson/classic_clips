defmodule ClassicClips.ClassicsTest do
  use ClassicClips.DataCase

  alias ClassicClips.Classics

  describe "videos" do
    alias ClassicClips.Classics.Video

    @valid_attrs %{description: "some description", publish_date: "some publish_date", title: "some title", type: "some type", yt_thumbnail_url: "some yt_thumbnail_url", yt_video_id: "some yt_video_id", yt_video_url: "some yt_video_url"}
    @update_attrs %{description: "some updated description", publish_date: "some updated publish_date", title: "some updated title", type: "some updated type", yt_thumbnail_url: "some updated yt_thumbnail_url", yt_video_id: "some updated yt_video_id", yt_video_url: "some updated yt_video_url"}
    @invalid_attrs %{description: nil, publish_date: nil, title: nil, type: nil, yt_thumbnail_url: nil, yt_video_id: nil, yt_video_url: nil}

    def video_fixture(attrs \\ %{}) do
      {:ok, video} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Classics.create_video()

      video
    end

    test "list_videos/0 returns all videos" do
      video = video_fixture()
      assert Classics.list_videos() == [video]
    end

    test "get_video!/1 returns the video with given id" do
      video = video_fixture()
      assert Classics.get_video!(video.id) == video
    end

    test "create_video/1 with valid data creates a video" do
      assert {:ok, %Video{} = video} = Classics.create_video(@valid_attrs)
      assert video.description == "some description"
      assert video.publish_date == "some publish_date"
      assert video.title == "some title"
      assert video.type == "some type"
      assert video.yt_thumbnail_url == "some yt_thumbnail_url"
      assert video.yt_video_id == "some yt_video_id"
      assert video.yt_video_url == "some yt_video_url"
    end

    test "create_video/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classics.create_video(@invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      video = video_fixture()
      assert {:ok, %Video{} = video} = Classics.update_video(video, @update_attrs)
      assert video.description == "some updated description"
      assert video.publish_date == "some updated publish_date"
      assert video.title == "some updated title"
      assert video.type == "some updated type"
      assert video.yt_thumbnail_url == "some updated yt_thumbnail_url"
      assert video.yt_video_id == "some updated yt_video_id"
      assert video.yt_video_url == "some updated yt_video_url"
    end

    test "update_video/2 with invalid data returns error changeset" do
      video = video_fixture()
      assert {:error, %Ecto.Changeset{}} = Classics.update_video(video, @invalid_attrs)
      assert video == Classics.get_video!(video.id)
    end

    test "delete_video/1 deletes the video" do
      video = video_fixture()
      assert {:ok, %Video{}} = Classics.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Classics.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      video = video_fixture()
      assert %Ecto.Changeset{} = Classics.change_video(video)
    end
  end
end
