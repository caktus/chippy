defmodule ChippyWeb.SprintLive.New do
  use Phoenix.LiveView
  alias Chippy.{SprintServer, SprintSupervisor}
  alias ChippyWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ChippyWeb.PageView.render("sprint_live_new.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, %{
      already_exists: false,
      sprint_name: "",
      other_errors: ""
    })}
  end

  def handle_event("lookup_name", %{"name" => name}, socket) do
    pid_or_nil = name |> SprintServer.via_tuple() |> GenServer.whereis()

    {:noreply, assign(socket, already_exists: is_pid(pid_or_nil))}
  end

  def handle_event("create", %{"name" => name}, socket) do
    new_sprint = SprintSupervisor.start_sprint(name, [])
    case new_sprint do
      {:ok, _pid} -> 
        {:stop, socket
          |> put_flash(:info, "Sprint created! Let's place the chips!")
          |> redirect(to: Routes.live_path(socket, ChippyWeb.SprintLive, name))}
      {:error, _error} ->
        {:noreply, assign(socket, other_errors: "There was a problem ...")}
    end
  end
end