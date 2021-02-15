defmodule ClassicClips.BigBeefTest do
  use ClassicClips.DataCase

  alias ClassicClips.BigBeef

  describe "beefs" do
    alias ClassicClips.BigBeef.Beef

    @valid_attrs %{beef_count: 42, date_time: "some date_time", player: "some player"}
    @update_attrs %{beef_count: 43, date_time: "some updated date_time", player: "some updated player"}
    @invalid_attrs %{beef_count: nil, date_time: nil, player: nil}

    def beef_fixture(attrs \\ %{}) do
      {:ok, beef} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BigBeef.create_beef()

      beef
    end

    test "list_beefs/0 returns all beefs" do
      beef = beef_fixture()
      assert BigBeef.list_beefs() == [beef]
    end

    test "get_beef!/1 returns the beef with given id" do
      beef = beef_fixture()
      assert BigBeef.get_beef!(beef.id) == beef
    end

    test "create_beef/1 with valid data creates a beef" do
      assert {:ok, %Beef{} = beef} = BigBeef.create_beef(@valid_attrs)
      assert beef.beef_count == 42
      assert beef.date_time == "some date_time"
      assert beef.player == "some player"
    end

    test "create_beef/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BigBeef.create_beef(@invalid_attrs)
    end

    test "update_beef/2 with valid data updates the beef" do
      beef = beef_fixture()
      assert {:ok, %Beef{} = beef} = BigBeef.update_beef(beef, @update_attrs)
      assert beef.beef_count == 43
      assert beef.date_time == "some updated date_time"
      assert beef.player == "some updated player"
    end

    test "update_beef/2 with invalid data returns error changeset" do
      beef = beef_fixture()
      assert {:error, %Ecto.Changeset{}} = BigBeef.update_beef(beef, @invalid_attrs)
      assert beef == BigBeef.get_beef!(beef.id)
    end

    test "delete_beef/1 deletes the beef" do
      beef = beef_fixture()
      assert {:ok, %Beef{}} = BigBeef.delete_beef(beef)
      assert_raise Ecto.NoResultsError, fn -> BigBeef.get_beef!(beef.id) end
    end

    test "change_beef/1 returns a beef changeset" do
      beef = beef_fixture()
      assert %Ecto.Changeset{} = BigBeef.change_beef(beef)
    end
  end

  describe "players" do
    alias ClassicClips.BigBeef.Player

    @valid_attrs %{first_name: "some first_name", last_name: "some last_name", number: 42, team: "some team"}
    @update_attrs %{first_name: "some updated first_name", last_name: "some updated last_name", number: 43, team: "some updated team"}
    @invalid_attrs %{first_name: nil, last_name: nil, number: nil, team: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BigBeef.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert BigBeef.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert BigBeef.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = BigBeef.create_player(@valid_attrs)
      assert player.first_name == "some first_name"
      assert player.last_name == "some last_name"
      assert player.number == 42
      assert player.team == "some team"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BigBeef.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = BigBeef.update_player(player, @update_attrs)
      assert player.first_name == "some updated first_name"
      assert player.last_name == "some updated last_name"
      assert player.number == 43
      assert player.team == "some updated team"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = BigBeef.update_player(player, @invalid_attrs)
      assert player == BigBeef.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = BigBeef.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> BigBeef.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = BigBeef.change_player(player)
    end
  end
end
