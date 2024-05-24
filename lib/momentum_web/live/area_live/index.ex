defmodule MomentumWeb.AreaLive.Index do
  use MomentumWeb, :live_view

  alias Momentum.Constructor
  alias Momentum.Constructor.Area

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :areas, Constructor.list_areas())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Area")
    |> assign(:area, Constructor.get_area!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Area")
    |> assign(:area, %Area{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Areas")
    |> assign(:area, nil)
  end

  @impl true
  def handle_info({MomentumWeb.AreaLive.FormComponent, {:saved, area}}, socket) do
    {:noreply, stream_insert(socket, :areas, area)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    area = Constructor.get_area!(id)
    {:ok, _} = Constructor.delete_area(area)

    {:noreply, stream_delete(socket, :areas, area)}
  end
end
