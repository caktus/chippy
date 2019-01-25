defmodule ChippyWeb.SprintChannel do
  use Phoenix.Channel

  alias Chippy.SprintServer

  def join("sprint:" <> sid, _message, socket) do
    case SprintServer.sprint_pid(sid) do
      pid when is_pid(pid) ->
        {:ok, socket}

      nil ->
        {:error, "Sprint not found"}
    end
  end
end
