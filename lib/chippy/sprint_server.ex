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

  # Methods
  def display_by_users(sprint_name) do
    GenServer.call(via_tuple(sprint_name), {:display_by_users})
  end

  # Server callbacks

  def init(project_names) do
    sprint = Sprint.new(project_names)

    {:ok, sprint, @timeout}
  end

  def handle_call({:add_chip, project_name, person_name}, _from, sprint) do
    new_sprint = Sprint.add_chips(sprint, project_name, person_name, 1)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:remove_chip, project_name, person_name}, _from, sprint) do
    new_sprint = Sprint.remove_chips(sprint, project_name, person_name, 1)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:display_by_users}, _from, sprint) do
    {:reply, Sprint.display_by_users(sprint), sprint, @timeout}
  end

  def handle_info(:timeout, sprint) do
    {:stop, {:shutdown, :timeout}, sprint}
  end
end
