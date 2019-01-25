defmodule ChippyWeb.SprintChannel do
  use Phoenix.Channel

  def join("sprint:" <> _sid, _message, socket) do
    {:ok, socket}
  end
end
