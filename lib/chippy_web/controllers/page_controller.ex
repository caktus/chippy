defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller
  alias Phoenix.LiveView.Controller, as: LiveController

  alias Chippy.SprintSupervisor
  alias ChippyWeb.Router.Helpers, as: Routes

  def index(conn, _params) do
    sprints =
      Supervisor.which_children(SprintSupervisor)
      |> Enum.map(fn {_, pid, _, _} -> pid end)
      |> Enum.map(fn pid -> Registry.keys(:sprint_registry, pid) end)
      # Registry.keys returns a list, but we only want the first thing in it
      |> Enum.map(fn [head | tail] -> head end)

    conn
    |> assign(:sprints, sprints)
    |> render("index.html")
  end

  def profile(conn, _params) do
    conn
    |> render("profile.html")
  end

  def profile_save(conn, %{"profile" => %{"user_id" => user_id} = form}) do
    conn
    |> put_session(:user_id, String.trim(user_id))
    |> put_flash(:info, "Profile saved successfully.")
    |> redirect(to: Map.get(form, "next", Routes.page_path(conn, :index)))
  end

  def sprint(conn, %{"sid" => sprint_id}) do
    case get_session(conn, :user_id) || "" do
      user_id when user_id != "" ->
        LiveController.live_render(
          conn,
          ChippyWeb.SprintLive.Show,
          session: %{
            user_id: user_id,
            sprint_id: sprint_id
          }
        )

      _ ->
        conn
        |> put_flash(:error, "Please set a user name before accessing a sprint.")
        |> redirect(
          to:
            Routes.page_path(conn, :profile, next: Routes.page_path(conn, :sprint, sprint_id))
        )
    end
  end
end
