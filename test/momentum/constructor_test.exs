defmodule MomentumHq.ConstructorTest do
  use MomentumHqDataCase

  alias MomentumHq.Constructor

  describe "areas" do
    alias MomentumHq.Constructor.Area

    import MomentumHq.ConstructorFixtures

    @invalid_attrs %{name: nil, content: nil}

    test "list_areas/0 returns all areas" do
      area = area_fixture()
      assert Constructor.list_areas() == [area]
    end

    test "get_area!/1 returns the area with given id" do
      area = area_fixture()
      assert Constructor.get_area!(area.id) == area
    end

    test "create_area/1 with valid data creates a area" do
      valid_attrs = %{name: "some name", content: %{}}

      assert {:ok, %Area{} = area} = Constructor.create_area(valid_attrs)
      assert area.name == "some name"
      assert area.content == %{}
    end

    test "create_area/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Constructor.create_area(@invalid_attrs)
    end

    test "update_area/2 with valid data updates the area" do
      area = area_fixture()
      update_attrs = %{name: "some updated name", content: %{}}

      assert {:ok, %Area{} = area} = Constructor.update_area(area, update_attrs)
      assert area.name == "some updated name"
      assert area.content == %{}
    end

    test "update_area/2 with invalid data returns error changeset" do
      area = area_fixture()
      assert {:error, %Ecto.Changeset{}} = Constructor.update_area(area, @invalid_attrs)
      assert area == Constructor.get_area!(area.id)
    end

    test "delete_area/1 deletes the area" do
      area = area_fixture()
      assert {:ok, %Area{}} = Constructor.delete_area(area)
      assert_raise Ecto.NoResultsError, fn -> Constructor.get_area!(area.id) end
    end

    test "change_area/1 returns a area changeset" do
      area = area_fixture()
      assert %Ecto.Changeset{} = Constructor.change_area(area)
    end
  end
end
