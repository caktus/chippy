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
    by_users = SprintServer.display_by_users(sid)

    push(socket, "by_users", by_users)

    {:noreply, socket}
  end
end
