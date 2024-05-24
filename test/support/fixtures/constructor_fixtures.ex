defmodule Momentum.ConstructorFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Momentum.Constructor` context.
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
      |> Momentum.Constructor.create_area()

    area
  end
end
