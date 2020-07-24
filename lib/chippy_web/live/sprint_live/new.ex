defmodule ChippyWeb.SprintLive.New do
  use ChippyWeb, :live_view

  alias Chippy.{SprintServer, SprintSupervisor}

  def render(assigns) do
    ChippyWeb.PageView.render("sprint_live_new.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       already_exists: false,
       sprint_name: "",
       other_errors: ""
     })}
  end

  def handle_event("lookup_name", %{"name" => name}, socket) do
    pid_or_nil = name |> String.trim() |> SprintServer.via_tuple() |> GenServer.whereis()

    {:noreply, assign(socket, already_exists: is_pid(pid_or_nil))}
  end

  def handle_event("create", %{"name" => name}, socket) do
    name = String.trim(name)

    new_sprint =
      case name do
        "" ->
          {:error, "Name cannot be empty"}

        _ ->
          SprintSupervisor.start_sprint(name, [])
      end

    case new_sprint do
      {:ok, _pid} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sprint created! Let's place the chips!")
         |> push_redirect(to: Routes.live_path(socket, ChippyWeb.SprintLive.Show, name))}

      {:error, the_error} ->
        {:noreply, assign(socket, other_errors: "There was a problem ... #{the_error}")}
    end
  end
end
