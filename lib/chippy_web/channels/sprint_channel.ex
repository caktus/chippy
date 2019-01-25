defmodule ChippyWeb.SprintChannel do
  use Phoenix.Channel

  alias Chippy.SprintServer

  def join("sprint:" <> sid, _message, socket) do
    case SprintServer.sprint_pid(sid) do
      pid when is_pid(pid) ->
        send(self(), {:joined, sid})
        {:ok, socket}

      nil ->
        {:error, "Sprint not found"}
    end
  end

  def handle_info({:joined, sid}, socket) do
    display = SprintServer.display(sid)

    push(socket, "display", display)

    {:noreply, socket}
  end

  def handle_in("new_project", %{"project_name" => project_name}, socket) do
    "sprint:" <> sid = socket.topic

    case SprintServer.sprint_pid(sid) do
      pid when is_pid(pid) ->
        new_sprint = SprintServer.add_project(sid, project_name)
        broadcast!(socket, "display", new_sprint)
        {:noreply, socket}

      nil ->
        {:noreply, "Sprint not found"}
    end
  end

  def handle_in(
        "add_chip",
        %{"project_name" => project_name, "person_name" => person_name},
        socket
      ) do
    "sprint:" <> sid = socket.topic

    case SprintServer.sprint_pid(sid) do
      pid when is_pid(pid) ->
        new_sprint = SprintServer.add_chip(sid, project_name, person_name)
        broadcast!(socket, "display", new_sprint)
        {:noreply, socket}

      nil ->
        {:noreply, "Sprint not found"}
    end
  end

  def handle_in(
        "remove_chip",
        %{"project_name" => project_name, "person_name" => person_name},
        socket
      ) do
    "sprint:" <> sid = socket.topic

    case SprintServer.sprint_pid(sid) do
      pid when is_pid(pid) ->
        new_sprint = SprintServer.remove_chip(sid, project_name, person_name)
        broadcast!(socket, "display", new_sprint)
        {:noreply, socket}

      nil ->
        {:noreply, "Sprint not found"}
    end
  end
end
