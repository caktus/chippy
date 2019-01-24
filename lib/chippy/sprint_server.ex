defmodule Chippy.SprintServer do
  use GenServer

  alias Chippy.Sprint

  @timeout :timer.minutes(5)

  def start_link(sprint_name, project_names) do
    GenServer.start_link(__MODULE__, project_names, name: via_tuple(sprint_name))
  end

  def via_tuple(sprint_name) do
    {:via, Registry, {:sprint_registry, sprint_name}}
  end

  # Server callbacks

  def init(project_names) do
    sprint = Sprint.new(project_names)

    {:ok, sprint, @timeout}
  end

  def handle_call({:add_chip, project_name, person_name}, _from, sprint) do
    new_sprint = Sprint.add_chip(sprint, project_name, person_name)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:remove_chip, project_name, person_name}, _from, sprint) do
    new_sprint = Sprint.remove_chip(sprint, project_name, person_name)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_info(:timeout, sprint) do
    {:stop, {:shutdown, :timeout}, sprint}
  end
end