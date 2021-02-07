defmodule ClassicClipsWeb.ClipLiveTest do
  use ClassicClipsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ClassicClips.Timeline

  @create_attrs %{clip_length: 42, title: "some title", yt_video_url: "some yt_video_url"}
  @update_attrs %{clip_length: 43, title: "some updated title", yt_video_url: "some updated yt_video_url"}
  @invalid_attrs %{clip_length: nil, title: nil, yt_video_url: nil}

  defp fixture(:clip) do
    {:ok, clip} = Timeline.create_clip(@create_attrs)
    clip
  end

  defp create_clip(_) do
    clip = fixture(:clip)
    %{clip: clip}
  end

  describe "Index" do
    setup [:create_clip]

    test "lists all clips", %{conn: conn, clip: clip} do
      {:ok, _index_live, html} = live(conn, Routes.clip_index_path(conn, :index))

      assert html =~ "Listing Clips"
      assert html =~ clip.title
    end

    test "saves new clip", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.clip_index_path(conn, :index))

      assert index_live |> element("a", "New Clip") |> render_click() =~
               "New Clip"

      assert_patch(index_live, Routes.clip_index_path(conn, :new))

      assert index_live
             |> form("#clip-form", clip: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#clip-form", clip: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.clip_index_path(conn, :index))

      assert html =~ "Clip created successfully"
      assert html =~ "some title"
    end

    test "updates clip in listing", %{conn: conn, clip: clip} do
      {:ok, index_live, _html} = live(conn, Routes.clip_index_path(conn, :index))

      assert index_live |> element("#clip-#{clip.id} a", "Edit") |> render_click() =~
               "Edit Clip"

      assert_patch(index_live, Routes.clip_index_path(conn, :edit, clip))

      assert index_live
             |> form("#clip-form", clip: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#clip-form", clip: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.clip_index_path(conn, :index))

      assert html =~ "Clip updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes clip in listing", %{conn: conn, clip: clip} do
      {:ok, index_live, _html} = live(conn, Routes.clip_index_path(conn, :index))

      assert index_live |> element("#clip-#{clip.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#clip-#{clip.id}")
    end
  end

  describe "Show" do
    setup [:create_clip]

    test "displays clip", %{conn: conn, clip: clip} do
      {:ok, _show_live, html} = live(conn, Routes.clip_show_path(conn, :show, clip))

      assert html =~ "Show Clip"
      assert html =~ clip.title
    end

    test "updates clip within modal", %{conn: conn, clip: clip} do
      {:ok, show_live, _html} = live(conn, Routes.clip_show_path(conn, :show, clip))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Clip"

      assert_patch(show_live, Routes.clip_show_path(conn, :edit, clip))

      assert show_live
             |> form("#clip-form", clip: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#clip-form", clip: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.clip_show_path(conn, :show, clip))

      assert html =~ "Clip updated successfully"
      assert html =~ "some updated title"
    end
  end
end
