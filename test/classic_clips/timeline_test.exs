defmodule ClassicClips.TimelineTest do
  use ClassicClips.DataCase

  alias ClassicClips.Timeline

  describe "clips" do
    alias ClassicClips.Timeline.Clip

    @valid_attrs %{clip_length: 42, title: "some title", yt_video_url: "some yt_video_url"}
    @update_attrs %{clip_length: 43, title: "some updated title", yt_video_url: "some updated yt_video_url"}
    @invalid_attrs %{clip_length: nil, title: nil, yt_video_url: nil}

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
      assert clip.clip_length == 42
      assert clip.title == "some title"
      assert clip.yt_video_url == "some yt_video_url"
    end

    test "create_clip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_clip(@invalid_attrs)
    end

    test "update_clip/2 with valid data updates the clip" do
      clip = clip_fixture()
      assert {:ok, %Clip{} = clip} = Timeline.update_clip(clip, @update_attrs)
      assert clip.clip_length == 43
      assert clip.title == "some updated title"
      assert clip.yt_video_url == "some updated yt_video_url"
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

  describe "users" do
    alias ClassicClips.Timeline.User

    @valid_attrs %{active: true, email: "some email", username: "some username"}
    @update_attrs %{active: false, email: "some updated email", username: "some updated username"}
    @invalid_attrs %{active: nil, email: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Timeline.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Timeline.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Timeline.create_user(@valid_attrs)
      assert user.active == true
      assert user.email == "some email"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Timeline.update_user(user, @update_attrs)
      assert user.active == false
      assert user.email == "some updated email"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_user(user, @invalid_attrs)
      assert user == Timeline.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Timeline.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Timeline.change_user(user)
    end
  end

  describe "votes" do
    alias ClassicClips.Timeline.Vote

    @valid_attrs %{"clip_id,": "some clip_id,", up: true, "user_id,": "some user_id,"}
    @update_attrs %{"clip_id,": "some updated clip_id,", up: false, "user_id,": "some updated user_id,"}
    @invalid_attrs %{"clip_id,": nil, up: nil, "user_id,": nil}

    def vote_fixture(attrs \\ %{}) do
      {:ok, vote} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_vote()

      vote
    end

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Timeline.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Timeline.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      assert {:ok, %Vote{} = vote} = Timeline.create_vote(@valid_attrs)
      assert vote.clip_id, == "some clip_id,"
      assert vote.up == true
      assert vote.user_id, == "some user_id,"
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{} = vote} = Timeline.update_vote(vote, @update_attrs)
      assert vote.clip_id, == "some updated clip_id,"
      assert vote.up == false
      assert vote.user_id, == "some updated user_id,"
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_vote(vote, @invalid_attrs)
      assert vote == Timeline.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Timeline.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Timeline.change_vote(vote)
    end
  end
end
