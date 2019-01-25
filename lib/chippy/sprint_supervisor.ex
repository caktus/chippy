defmodule Chippy.SprintSupervisor do
  use DynamicSupervisor

  alias Chippy.SprintServer

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_sprint(sprint_name, project_names) do
    DynamicSupervisor.start_child(__MODULE__, %{
      id: SprintServer,
      start: {SprintServer, :start_link, [sprint_name, project_names]},
      restart: :transient
    })
  end

  def stop_sprint(sprint_name) do
    sprint_pid =
      sprint_name
      |> SprintServer.via_tuple()
      |> GenServer.whereis()

    DynamicSupervisor.terminate_child(__MODULE__, sprint_pid)
  end
end
