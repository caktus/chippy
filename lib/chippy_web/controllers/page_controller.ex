defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller

  alias Chippy.{SprintServer, SprintSupervisor}
  alias Phoenix.LiveView

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
        redirect(conn, to: Routes.page_path(conn, :sprint, random_name))

      {:error, _error} ->
        conn
        |> put_flash(:error, "Error! Error!!")
        |> redirect(to: Routes.page_path(conn, :new))
    end
  end

  def sprint(conn, %{"sid" => sprint_id}) do
    pid_or_nil = sprint_id |> SprintServer.via_tuple() |> GenServer.whereis()

    case pid_or_nil do
      pid when is_pid(pid) ->
        LiveView.Controller.live_render(
          conn,
          ChippyWeb.SprintLive,
          session: %{
            sprint_id: sprint_id,
            by_users: SprintServer.display_by_users(sprint_id)
          }
        )
      nil ->
        conn
        |> put_flash(:error, "Sprint not found.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
