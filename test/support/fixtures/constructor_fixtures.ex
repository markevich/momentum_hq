defmodule MomentumHq.ConstructorFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MomentumHq.Constructor` context.
  """

  @doc """
  Generate a area.
  """
  def area_fixture(attrs \\ %{}) do
    {:ok, area} =
      attrs
      |> Enum.into(%{
        content: %{},
        name: "some name"
      })
      |> MomentumHq.Constructor.create_area()

    area
  end
end
