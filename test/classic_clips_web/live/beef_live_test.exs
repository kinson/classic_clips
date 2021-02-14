defmodule ClassicClipsWeb.BeefLiveTest do
  use ClassicClipsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ClassicClips.BigBeef

  @create_attrs %{beef_count: 42, date_time: "some date_time", player: "some player"}
  @update_attrs %{beef_count: 43, date_time: "some updated date_time", player: "some updated player"}
  @invalid_attrs %{beef_count: nil, date_time: nil, player: nil}

  defp fixture(:beef) do
    {:ok, beef} = BigBeef.create_beef(@create_attrs)
    beef
  end

  defp create_beef(_) do
    beef = fixture(:beef)
    %{beef: beef}
  end

  describe "Index" do
    setup [:create_beef]

    test "lists all beefs", %{conn: conn, beef: beef} do
      {:ok, _index_live, html} = live(conn, Routes.beef_index_path(conn, :index))

      assert html =~ "Listing Beefs"
      assert html =~ beef.date_time
    end

    test "saves new beef", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.beef_index_path(conn, :index))

      assert index_live |> element("a", "New Beef") |> render_click() =~
               "New Beef"

      assert_patch(index_live, Routes.beef_index_path(conn, :new))

      assert index_live
             |> form("#beef-form", beef: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#beef-form", beef: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.beef_index_path(conn, :index))

      assert html =~ "Beef created successfully"
      assert html =~ "some date_time"
    end

    test "updates beef in listing", %{conn: conn, beef: beef} do
      {:ok, index_live, _html} = live(conn, Routes.beef_index_path(conn, :index))

      assert index_live |> element("#beef-#{beef.id} a", "Edit") |> render_click() =~
               "Edit Beef"

      assert_patch(index_live, Routes.beef_index_path(conn, :edit, beef))

      assert index_live
             |> form("#beef-form", beef: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#beef-form", beef: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.beef_index_path(conn, :index))

      assert html =~ "Beef updated successfully"
      assert html =~ "some updated date_time"
    end

    test "deletes beef in listing", %{conn: conn, beef: beef} do
      {:ok, index_live, _html} = live(conn, Routes.beef_index_path(conn, :index))

      assert index_live |> element("#beef-#{beef.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#beef-#{beef.id}")
    end
  end

  describe "Show" do
    setup [:create_beef]

    test "displays beef", %{conn: conn, beef: beef} do
      {:ok, _show_live, html} = live(conn, Routes.beef_show_path(conn, :show, beef))

      assert html =~ "Show Beef"
      assert html =~ beef.date_time
    end

    test "updates beef within modal", %{conn: conn, beef: beef} do
      {:ok, show_live, _html} = live(conn, Routes.beef_show_path(conn, :show, beef))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Beef"

      assert_patch(show_live, Routes.beef_show_path(conn, :edit, beef))

      assert show_live
             |> form("#beef-form", beef: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#beef-form", beef: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.beef_show_path(conn, :show, beef))

      assert html =~ "Beef updated successfully"
      assert html =~ "some updated date_time"
    end
  end
end
