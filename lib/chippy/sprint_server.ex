defmodule Chippy.SprintServer do
  use GenServer

  alias Chippy.Sprint

  @timeout :timer.minutes(120)

  def start_link(sprint_name, project_names) do
    GenServer.start_link(__MODULE__, project_names, name: via_tuple(sprint_name))
  end

  def via_tuple(sprint_name) do
    {:via, Registry, {:sprint_registry, sprint_name}}
  end

  # Methods
  def add_project(sprint_name, project_name, hour_limit) do
    sprint_name
    |> via_tuple
    |> GenServer.call({:add_project, project_name, hour_limit})
  end

  def delete_project(sprint_name, project_name) do
    sprint_name
    |> via_tuple
    |> GenServer.call({:delete_project, project_name})
  end

  def has_project?(sprint_name, project_name) do
    sprint_name
    |> via_tuple
    |> GenServer.call({:has_project, project_name})
  end

  def add_chip(sprint_name, project_name, person_name) do
    sprint_name
    |> via_tuple
    |> GenServer.call({:add_chip, project_name, person_name})
  end

  def remove_chip(sprint_name, project_name, person_name) do
    sprint_name
    |> via_tuple
    |> GenServer.call({:remove_chip, project_name, person_name})
  end

  def display(sprint_name) do
    sprint_name
    |> via_tuple
    |> GenServer.call({:display})
  end

  def display_by_users(sprint_name) do
    GenServer.call(via_tuple(sprint_name), {:display_by_users})
  end

  def sprint_pid(sprint_name) do
    sprint_name |> via_tuple |> GenServer.whereis()
  end

  # Server callbacks

  def init(project_names) do
    sprint = Sprint.new(project_names)

    {:ok, sprint, @timeout}
  end

  def handle_call({:add_project, project_name, hour_limit}, _from, sprint) do
    new_sprint = Sprint.add_project(sprint, project_name, hour_limit)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:has_project, project_name}, _from, sprint) do
    {:reply, Sprint.has_project?(sprint, project_name), sprint, @timeout}
  end

  def handle_call({:delete_project, project_name}, _from, sprint) do
    new_sprint = Sprint.delete_project(sprint, project_name)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:add_chip, project_name, person_name}, _from, sprint) do
    new_sprint = Sprint.add_chips(sprint, project_name, person_name, 1)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:remove_chip, project_name, person_name}, _from, sprint) do
    new_sprint = Sprint.remove_chips(sprint, project_name, person_name, 1)
    {:reply, new_sprint, new_sprint, @timeout}
  end

  def handle_call({:display}, _from, sprint) do
    {:reply, sprint, sprint, @timeout}
  end

  def handle_call({:display_by_users}, _from, sprint) do
    {:reply, Sprint.display_by_users(sprint), sprint, @timeout}
  end

  def handle_info(:timeout, sprint) do
    {:stop, {:shutdown, :timeout}, sprint}
  end
end
