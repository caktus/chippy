defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller

  alias Chippy.{Sprint, SprintServer, SprintSupervisor}

  def index(conn, _params) do
    render(conn, "index.html")
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

    render(conn, "index.html")
  end

  # NOTE: pretty much immediately I'm going to want to replace
  # this with a React view, now that I'm thinking about it ...
  def sprint(conn, %{"sid" => sprint_id}) do
    pid_or_nil = sprint_id |> SprintServer.via_tuple() |> GenServer.whereis()

    case pid_or_nil do
      pid when is_pid(pid) ->
        conn
        |> assign(:by_users, SprintServer.display_by_users(sprint_id))
        # TODO: do something with :by_users value?
        |> render("sprint.html")

      nil ->
        conn
        |> put_flash(:error, "Sprint not found.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
