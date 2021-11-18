defmodule ClassicClips.PickEmTest do
  use ClassicClips.DataCase

  alias ClassicClips.PickEm

  describe "teams" do
    alias ClassicClips.PickEm.Team

    import ClassicClips.PickEmFixtures

    @invalid_attrs %{abbreviation: nil, location: nil, name: nil}

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert PickEm.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert PickEm.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{
        abbreviation: "some abbreviation",
        location: "some location",
        name: "some name"
      }

      assert {:ok, %Team{} = team} = PickEm.create_team(valid_attrs)
      assert team.abbreviation == "some abbreviation"
      assert team.location == "some location"
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PickEm.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()

      update_attrs = %{
        abbreviation: "some updated abbreviation",
        location: "some updated location",
        name: "some updated name"
      }

      assert {:ok, %Team{} = team} = PickEm.update_team(team, update_attrs)
      assert team.abbreviation == "some updated abbreviation"
      assert team.location == "some updated location"
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = PickEm.update_team(team, @invalid_attrs)
      assert team == PickEm.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = PickEm.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> PickEm.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = PickEm.change_team(team)
    end
  end

  describe "match_ups" do
    alias ClassicClips.PickEm.MatchUp

    import ClassicClips.PickEmFixtures

    @invalid_attrs %{date: nil, month: nil, score: nil, spread: nil, tip_time: nil}

    test "list_match_ups/0 returns all match_ups" do
      match_up = match_up_fixture()
      assert PickEm.list_match_ups() == [match_up]
    end

    test "get_match_up!/1 returns the match_up with given id" do
      match_up = match_up_fixture()
      assert PickEm.get_match_up!(match_up.id) == match_up
    end

    test "create_match_up/1 with valid data creates a match_up" do
      valid_attrs = %{
        date: ~D[2021-10-30],
        month: "some month",
        score: "some score",
        spread: "some spread",
        tip_time: ~T[14:00:00]
      }

      assert {:ok, %MatchUp{} = match_up} = PickEm.create_match_up(valid_attrs)
      assert match_up.date == ~D[2021-10-30]
      assert match_up.month == "some month"
      assert match_up.score == "some score"
      assert match_up.spread == "some spread"
      assert match_up.tip_time == ~T[14:00:00]
    end

    test "create_match_up/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PickEm.create_match_up(@invalid_attrs)
    end

    test "update_match_up/2 with valid data updates the match_up" do
      match_up = match_up_fixture()

      update_attrs = %{
        date: ~D[2021-10-31],
        month: "some updated month",
        score: "some updated score",
        spread: "some updated spread",
        tip_time: ~T[15:01:01]
      }

      assert {:ok, %MatchUp{} = match_up} = PickEm.update_match_up(match_up, update_attrs)
      assert match_up.date == ~D[2021-10-31]
      assert match_up.month == "some updated month"
      assert match_up.score == "some updated score"
      assert match_up.spread == "some updated spread"
      assert match_up.tip_time == ~T[15:01:01]
    end

    test "update_match_up/2 with invalid data returns error changeset" do
      match_up = match_up_fixture()
      assert {:error, %Ecto.Changeset{}} = PickEm.update_match_up(match_up, @invalid_attrs)
      assert match_up == PickEm.get_match_up!(match_up.id)
    end

    test "delete_match_up/1 deletes the match_up" do
      match_up = match_up_fixture()
      assert {:ok, %MatchUp{}} = PickEm.delete_match_up(match_up)
      assert_raise Ecto.NoResultsError, fn -> PickEm.get_match_up!(match_up.id) end
    end

    test "change_match_up/1 returns a match_up changeset" do
      match_up = match_up_fixture()
      assert %Ecto.Changeset{} = PickEm.change_match_up(match_up)
    end
  end

  describe "user_picks" do
    alias ClassicClips.PickEm.UserPick

    import ClassicClips.PickEmFixtures

    @invalid_attrs %{result: nil}

    test "list_user_picks/0 returns all user_picks" do
      user_pick = user_pick_fixture()
      assert PickEm.list_user_picks() == [user_pick]
    end

    test "get_user_pick!/1 returns the user_pick with given id" do
      user_pick = user_pick_fixture()
      assert PickEm.get_user_pick!(user_pick.id) == user_pick
    end

    test "create_user_pick/1 with valid data creates a user_pick" do
      valid_attrs = %{result: "some result"}

      assert {:ok, %UserPick{} = user_pick} = PickEm.create_user_pick(valid_attrs)
      assert user_pick.result == "some result"
    end

    test "create_user_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PickEm.create_user_pick(@invalid_attrs)
    end

    test "update_user_pick/2 with valid data updates the user_pick" do
      user_pick = user_pick_fixture()
      update_attrs = %{result: "some updated result"}

      assert {:ok, %UserPick{} = user_pick} = PickEm.update_user_pick(user_pick, update_attrs)
      assert user_pick.result == "some updated result"
    end

    test "update_user_pick/2 with invalid data returns error changeset" do
      user_pick = user_pick_fixture()
      assert {:error, %Ecto.Changeset{}} = PickEm.update_user_pick(user_pick, @invalid_attrs)
      assert user_pick == PickEm.get_user_pick!(user_pick.id)
    end

    test "delete_user_pick/1 deletes the user_pick" do
      user_pick = user_pick_fixture()
      assert {:ok, %UserPick{}} = PickEm.delete_user_pick(user_pick)
      assert_raise Ecto.NoResultsError, fn -> PickEm.get_user_pick!(user_pick.id) end
    end

    test "change_user_pick/1 returns a user_pick changeset" do
      user_pick = user_pick_fixture()
      assert %Ecto.Changeset{} = PickEm.change_user_pick(user_pick)
    end
  end

  describe "ndc_picks" do
    alias ClassicClips.PickEm.NdcPick

    import ClassicClips.PickEmFixtures

    @invalid_attrs %{}

    test "list_ndc_picks/0 returns all ndc_picks" do
      ndc_pick = ndc_pick_fixture()
      assert PickEm.list_ndc_picks() == [ndc_pick]
    end

    test "get_ndc_pick!/1 returns the ndc_pick with given id" do
      ndc_pick = ndc_pick_fixture()
      assert PickEm.get_ndc_pick!(ndc_pick.id) == ndc_pick
    end

    test "create_ndc_pick/1 with valid data creates a ndc_pick" do
      valid_attrs = %{}

      assert {:ok, %NdcPick{} = ndc_pick} = PickEm.create_ndc_pick(valid_attrs)
    end

    test "create_ndc_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PickEm.create_ndc_pick(@invalid_attrs)
    end

    test "update_ndc_pick/2 with valid data updates the ndc_pick" do
      ndc_pick = ndc_pick_fixture()
      update_attrs = %{}

      assert {:ok, %NdcPick{} = ndc_pick} = PickEm.update_ndc_pick(ndc_pick, update_attrs)
    end

    test "update_ndc_pick/2 with invalid data returns error changeset" do
      ndc_pick = ndc_pick_fixture()
      assert {:error, %Ecto.Changeset{}} = PickEm.update_ndc_pick(ndc_pick, @invalid_attrs)
      assert ndc_pick == PickEm.get_ndc_pick!(ndc_pick.id)
    end

    test "delete_ndc_pick/1 deletes the ndc_pick" do
      ndc_pick = ndc_pick_fixture()
      assert {:ok, %NdcPick{}} = PickEm.delete_ndc_pick(ndc_pick)
      assert_raise Ecto.NoResultsError, fn -> PickEm.get_ndc_pick!(ndc_pick.id) end
    end

    test "change_ndc_pick/1 returns a ndc_pick changeset" do
      ndc_pick = ndc_pick_fixture()
      assert %Ecto.Changeset{} = PickEm.change_ndc_pick(ndc_pick)
    end
  end

  describe "user_records" do
    alias ClassicClips.PickEm.UserRecord

    import ClassicClips.PickEmFixtures

    @invalid_attrs %{lossses: nil, month: nil, wins: nil}

    test "list_user_records/0 returns all user_records" do
      user_record = user_record_fixture()
      assert PickEm.list_user_records() == [user_record]
    end

    test "get_user_record!/1 returns the user_record with given id" do
      user_record = user_record_fixture()
      assert PickEm.get_user_record!(user_record.id) == user_record
    end

    test "create_user_record/1 with valid data creates a user_record" do
      valid_attrs = %{lossses: 42, month: "some month", wins: 42}

      assert {:ok, %UserRecord{} = user_record} = PickEm.create_user_record(valid_attrs)
      assert user_record.lossses == 42
      assert user_record.month == "some month"
      assert user_record.wins == 42
    end

    test "create_user_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PickEm.create_user_record(@invalid_attrs)
    end

    test "update_user_record/2 with valid data updates the user_record" do
      user_record = user_record_fixture()
      update_attrs = %{lossses: 43, month: "some updated month", wins: 43}

      assert {:ok, %UserRecord{} = user_record} =
               PickEm.update_user_record(user_record, update_attrs)

      assert user_record.lossses == 43
      assert user_record.month == "some updated month"
      assert user_record.wins == 43
    end

    test "update_user_record/2 with invalid data returns error changeset" do
      user_record = user_record_fixture()
      assert {:error, %Ecto.Changeset{}} = PickEm.update_user_record(user_record, @invalid_attrs)
      assert user_record == PickEm.get_user_record!(user_record.id)
    end

    test "delete_user_record/1 deletes the user_record" do
      user_record = user_record_fixture()
      assert {:ok, %UserRecord{}} = PickEm.delete_user_record(user_record)
      assert_raise Ecto.NoResultsError, fn -> PickEm.get_user_record!(user_record.id) end
    end

    test "change_user_record/1 returns a user_record changeset" do
      user_record = user_record_fixture()
      assert %Ecto.Changeset{} = PickEm.change_user_record(user_record)
    end
  end
end
