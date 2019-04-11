defmodule ChippyWeb.SprintLive do
  use Phoenix.LiveView

  def render(assigns) do
    ChippyWeb.PageView.render("sprint_live.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, socket}
  end
end