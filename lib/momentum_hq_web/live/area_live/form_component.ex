defmodule MomentumHqWeb.AreaLive.FormComponent do
  use MomentumHqWeb, :live_component

  alias MomentumHq.Constructor

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage area records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="area-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Area</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{area: area} = assigns, socket) do
    changeset = Constructor.change_area(area)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"area" => area_params}, socket) do
    changeset =
      socket.assigns.area
      |> Constructor.change_area(area_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"area" => area_params}, socket) do
    save_area(socket, socket.assigns.action, area_params)
  end

  defp save_area(socket, :edit, area_params) do
    case Constructor.update_area(socket.assigns.area, area_params) do
      {:ok, area} ->
        notify_parent({:saved, area})

        {:noreply,
         socket
         |> put_flash(:info, "Area updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_area(socket, :new, area_params) do
    case Constructor.create_area(area_params) do
      {:ok, area} ->
        notify_parent({:saved, area})

        {:noreply,
         socket
         |> put_flash(:info, "Area created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
