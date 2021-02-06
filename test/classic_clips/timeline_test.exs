defmodule ClassicClips.TimelineTest do
  use ClassicClips.DataCase

  alias ClassicClips.Timeline

  describe "clips" do
    alias ClassicClips.Timeline.Clip

    @valid_attrs %{start_time: 42, title: "some title", video_ext_id: "some video_ext_id"}
    @update_attrs %{start_time: 43, title: "some updated title", video_ext_id: "some updated video_ext_id"}
    @invalid_attrs %{start_time: nil, title: nil, video_ext_id: nil}

    def clip_fixture(attrs \\ %{}) do
      {:ok, clip} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_clip()

      clip
    end

    test "list_clips/0 returns all clips" do
      clip = clip_fixture()
      assert Timeline.list_clips() == [clip]
    end

    test "get_clip!/1 returns the clip with given id" do
      clip = clip_fixture()
      assert Timeline.get_clip!(clip.id) == clip
    end

    test "create_clip/1 with valid data creates a clip" do
      assert {:ok, %Clip{} = clip} = Timeline.create_clip(@valid_attrs)
      assert clip.start_time == 42
      assert clip.title == "some title"
      assert clip.video_ext_id == "some video_ext_id"
    end

    test "create_clip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_clip(@invalid_attrs)
    end

    test "update_clip/2 with valid data updates the clip" do
      clip = clip_fixture()
      assert {:ok, %Clip{} = clip} = Timeline.update_clip(clip, @update_attrs)
      assert clip.start_time == 43
      assert clip.title == "some updated title"
      assert clip.video_ext_id == "some updated video_ext_id"
    end

    test "update_clip/2 with invalid data returns error changeset" do
      clip = clip_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_clip(clip, @invalid_attrs)
      assert clip == Timeline.get_clip!(clip.id)
    end

    test "delete_clip/1 deletes the clip" do
      clip = clip_fixture()
      assert {:ok, %Clip{}} = Timeline.delete_clip(clip)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_clip!(clip.id) end
    end

    test "change_clip/1 returns a clip changeset" do
      clip = clip_fixture()
      assert %Ecto.Changeset{} = Timeline.change_clip(clip)
    end
  end
end
