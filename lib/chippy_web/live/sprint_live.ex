defmodule ChippyWeb.SprintLive do
  use Phoenix.LiveView

  def render(assigns) do
    ChippyWeb.PageView.render("sprint_live.html", assigns)
  end

  def mount(%{sprint_id: sprint_id, by_users: by_users}, socket) do
    new_sock = socket
      |> assign(sprint_id: sprint_id)
      |> assign(by_users: by_users)
    {:ok, new_sock}
  end
end