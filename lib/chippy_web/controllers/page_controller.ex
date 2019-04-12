defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller
  
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

  def new(conn, _params) do
    random_name = :crypto.strong_rand_bytes(8) |> Base.url_encode64() |> binary_part(0, 8)

    case SprintSupervisor.start_sprint(random_name, []) do
      {:ok, _pid} ->
        redirect(conn, to: Routes.live_path(ChippyWeb.Endpoint, ChippyWeb.SprintLive, random_name))

      {:error, _error} ->
        conn
        |> put_flash(:error, "Error! Error!!")
        |> redirect(to: Routes.page_path(conn, :new))
    end
  end
end
