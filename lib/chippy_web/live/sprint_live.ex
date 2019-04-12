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
        new_sock = socket
          |> assign(sprint_id: sprint_id)
          |> assign(by_users: SprintServer.display_by_users(sprint_id))
          |> assign(your_name: user_id)
          |> assign(your_color: user_color)
        {:ok, new_sock}
      nil ->
        {:stop,
          socket
          |> put_flash(:error, "Sprint not found.")
          |> redirect(to: Routes.page_path(ChippyWeb.Endpoint, :index))}
    end
  end
end