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
end
