defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller
  alias Phoenix.LiveView.Controller, as: LiveController
  
  alias Chippy.{SprintServer, SprintSupervisor}
  alias ChippyWeb.Router.Helpers, as: Routes

  def index(conn, _params) do
    sprints =
      Supervisor.which_children(Chippy.SprintSupervisor)
      |> Enum.map(fn {_, pid, _, _} -> pid end)
      |> Enum.map(fn pid -> Registry.keys(:sprint_registry, pid) end)

    conn
    |> assign(:sprints, sprints)
    |> render("index.html")
  end

  def sprint(conn, %{"sid" => sprint_id}) do
    LiveController.live_render(
      conn,
      ChippyWeb.SprintLive,
      session: %{
        user_id: conn.cookies["user_id"],
        user_color: conn.cookies["user_color"],
        sprint_id: sprint_id
      }
    )
  end
end
