defmodule MomentumHqWeb.AreaLiveTest do
  use MomentumHqWeb.ConnCase

  import Phoenix.LiveViewTest
  import MomentumHq.ConstructorFixtures

  @create_attrs %{name: "some name", content: %{}}
  @update_attrs %{name: "some updated name", content: %{}}
  @invalid_attrs %{name: nil, content: nil}

  defp create_area(_) do
    area = area_fixture()
    %{area: area}
  end

  describe "Index" do
    setup [:create_area]

    test "lists all areas", %{conn: conn, area: area} do
      {:ok, _index_live, html} = live(conn, ~p"/areas")

      assert html =~ "Listing Areas"
      assert html =~ area.name
    end

    test "saves new area", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/areas")

      assert index_live |> element("a", "New Area") |> render_click() =~
               "New Area"

      assert_patch(index_live, ~p"/areas/new")

      assert index_live
             |> form("#area-form", area: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#area-form", area: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/areas")

      html = render(index_live)
      assert html =~ "Area created successfully"
      assert html =~ "some name"
    end

    test "updates area in listing", %{conn: conn, area: area} do
      {:ok, index_live, _html} = live(conn, ~p"/areas")

      assert index_live |> element("#areas-#{area.id} a", "Edit") |> render_click() =~
               "Edit Area"

      assert_patch(index_live, ~p"/areas/#{area}/edit")

      assert index_live
             |> form("#area-form", area: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#area-form", area: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/areas")

      html = render(index_live)
      assert html =~ "Area updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes area in listing", %{conn: conn, area: area} do
      {:ok, index_live, _html} = live(conn, ~p"/areas")

      assert index_live |> element("#areas-#{area.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#areas-#{area.id}")
    end
  end

  describe "Show" do
    setup [:create_area]

    test "displays area", %{conn: conn, area: area} do
      {:ok, _show_live, html} = live(conn, ~p"/areas/#{area}")

      assert html =~ "Show Area"
      assert html =~ area.name
    end

    test "updates area within modal", %{conn: conn, area: area} do
      {:ok, show_live, _html} = live(conn, ~p"/areas/#{area}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Area"

      assert_patch(show_live, ~p"/areas/#{area}/show/edit")

      assert show_live
             |> form("#area-form", area: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#area-form", area: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/areas/#{area}")

      html = render(show_live)
      assert html =~ "Area updated successfully"
      assert html =~ "some updated name"
    end
  end
end
