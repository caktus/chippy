defmodule ChippyWeb.SprintLive.Show do
  use Phoenix.LiveView

  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast
  alias Chippy.{SprintServer}
  alias ChippyWeb.Presence
  alias ChippyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    assigns = Map.put(assigns, :hours_per_chip, Application.get_env(:chippy, :hours_per_chip))
    ChippyWeb.PageView.render("sprint_live.html", assigns)
  end

  defp user_chip_counts(sprint_id) do
    SprintServer.display_by_users(sprint_id)
    # Create a map of %{"username" => %{chip_count: N}} for all users in the Sprint
    |> Map.new(fn {name, projects} ->
      {name, %{chip_count: projects |> Map.values() |> Enum.sum()}}
    end)
  end

  defp sprint_users(sprint_id) do
    Presence.list("users:" <> sprint_id)
    # Create a map of %{"username" => %{device_count: N}} for all online users
    |> Map.new(fn {name, %{metas: metas}} -> {name, %{device_count: length(metas)}} end)
    # Merge the map of online users with the users and their chip counts from the
    # SprintServer, so we end up with %{"username" => %{device_count: N, chip_count: N}}.
    # We need the nested Map.merge since we're merging both the top-level map and its
    # values per-key (which are also maps).
    |> Map.merge(user_chip_counts(sprint_id), fn _k, a, b -> Map.merge(a, b) end)
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
           sprint_users: sprint_users(sprint_id)
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
    {:noreply, assign(socket, %{sprint: new_sprint, sprint_users: sprint_users(sprint_id)})}
  end

  def handle_info(
        {:sprints, :update, new_sprint},
        %{assigns: %{sprint_id: sprint_id}} = socket
      ) do
    {:noreply, assign(socket, %{sprint: new_sprint, sprint_users: sprint_users(sprint_id)})}
  end

  def handle_info(
        %Broadcast{event: "presence_diff"},
        %{assigns: %{sprint_id: sprint_id}} = socket
      ) do
    {:noreply, assign(socket, sprint_users: sprint_users(sprint_id))}
  end
end
