defmodule ChippyWeb.SprintLive.Show do
  use Phoenix.LiveView

  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast
  alias Chippy.{SprintServer}
  alias ChippyWeb.Presence
  alias ChippyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ChippyWeb.PageView.render("sprint_live.html", assigns)
  end

  def mount(%{user_id: user_id, sprint_id: sprint_id}, socket) do
    pid_or_nil = sprint_id |> SprintServer.via_tuple() |> GenServer.whereis()

    case pid_or_nil do
      pid when is_pid(pid) ->
        PubSub.subscribe(Chippy.PubSub, "sprint:" <> sprint_id)
        PubSub.subscribe(Chippy.PubSub, "users:" <> sprint_id)
        Presence.track(self(), "users:" <> sprint_id, user_id, %{})

        {:ok,
         assign(socket, %{
           sprint_id: sprint_id,
           sprint: SprintServer.display(sprint_id),
           your_name: user_id,
           name_taken: false,
           errors: "",
           project_name: "",
           online_users: Presence.list("users:" <> sprint_id)
         })}

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
    {:noreply,
     assign(socket,
       project_name: project_name,
       name_taken: SprintServer.has_project?(sprint_id, project_name)
     )}
  end

  def handle_event(
        "create_project",
        %{"project_name" => project_name},
        %{assigns: %{sprint_id: sprint_id}} = socket
      ) do
    new_sprint = SprintServer.add_project(sprint_id, project_name)
    update_sprint(sprint_id, new_sprint, socket)
  end

  def handle_event(
        "add_chip",
        project_name,
        %{assigns: %{sprint_id: sprint_id, your_name: person_name}} = socket
      ) do
    new_sprint = SprintServer.add_chip(sprint_id, project_name, person_name)
    update_sprint(sprint_id, new_sprint, socket)
  end

  def handle_event(
        "remove_chip",
        project_name,
        %{assigns: %{sprint_id: sprint_id, your_name: person_name}} = socket
      ) do
    new_sprint = SprintServer.remove_chip(sprint_id, project_name, person_name)
    update_sprint(sprint_id, new_sprint, socket)
  end

  def update_sprint(sprint_id, new_sprint, socket) do
    PubSub.broadcast(Chippy.PubSub, "sprint:" <> sprint_id, {:sprints, :update, new_sprint})
    {:noreply, assign(socket, sprint: new_sprint)}
  end

  def handle_info({:sprints, :update, new_sprint}, socket) do
    {:noreply, assign(socket, sprint: new_sprint)}
  end

  def handle_info(%Broadcast{event: "presence_diff"}, %{assigns: %{sprint_id: sprint_id}} = socket) do
    {:noreply, assign(socket, online_users: Presence.list("users:" <> sprint_id))}
  end
end
