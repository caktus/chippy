defmodule ChippyWeb.SprintLive do
  use Phoenix.LiveView

  alias Chippy.{SprintServer}
  alias ChippyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ChippyWeb.PageView.render("sprint_live.html", assigns)
  end

  def mount(%{user_id: user_id, user_color: user_color, sprint_id: sprint_id}, socket) do
    pid_or_nil = sprint_id |> SprintServer.via_tuple() |> GenServer.whereis()

    case pid_or_nil do
      pid when is_pid(pid) ->
        new_sock =
          socket
          |> assign(sprint_id: sprint_id)
          |> assign(sprint: SprintServer.display(sprint_id))
          |> assign(your_name: user_id)
          |> assign(your_color: user_color)
          |> assign(name_taken: false)
          |> assign(errors: "")
          |> assign(project_name: "")

        {:ok, new_sock}

      nil ->
        {:stop,
         socket
         |> put_flash(:error, "Sprint not found.")
         |> redirect(to: Routes.page_path(ChippyWeb.Endpoint, :index))}
    end
  end

  def handle_event(
        "lookup_project",
        %{"project_name" => project_name},
        %{assigns: %{sprint_id: sprint_id}} = socket
      ) do
    {:noreply, assign(socket, name_taken: SprintServer.has_project?(sprint_id, project_name))}
  end

  def handle_event(
        "create_project",
        %{"project_name" => project_name},
        %{assigns: %{sprint_id: sprint_id}} = socket
      ) do
    new_sprint = SprintServer.add_project(sprint_id, project_name)
    {:noreply, assign(socket, sprint: new_sprint)}
  end

  def handle_event(
        "add_chip",
        project_name,
        %{assigns: %{sprint_id: sprint_id, your_name: person_name}} = socket
      ) do
    new_sprint = SprintServer.add_chip(sprint_id, project_name, person_name)
    {:noreply, assign(socket, sprint: new_sprint)}
  end

  def handle_event(
        "remove_chip",
        project_name,
        %{assigns: %{sprint_id: sprint_id, your_name: person_name}} = socket
      ) do
    new_sprint = SprintServer.remove_chip(sprint_id, project_name, person_name)
    {:noreply, assign(socket, sprint: new_sprint)}
  end
end