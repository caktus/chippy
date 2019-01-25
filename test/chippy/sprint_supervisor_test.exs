defmodule SprintSupervisorTest do
  use ExUnit.Case, async: true

  alias Chippy.{SprintServer, SprintSupervisor}

  test "spawns a sprint process" do
    SprintSupervisor.start_link(:ok)

    sprint_name = "scarlet_crown_sprint_123"
    projects = ["CMG", "Mind My Health"]

    assert {:ok, pid} = SprintSupervisor.start_sprint(sprint_name, projects)

    assert sprint_name
           |> SprintServer.via_tuple()
           |> GenServer.whereis()
           |> Process.alive?()
  end

  test "kills a sprint process" do
    SprintSupervisor.start_link(:ok)

    sprint_name = "scarlet_crown_sprint_123"
    projects = ["CMG", "Mind My Health"]

    assert {:ok, pid} = SprintSupervisor.start_sprint(sprint_name, projects)
    assert :ok = SprintSupervisor.stop_sprint(sprint_name)

    refute sprint_name
           |> SprintServer.via_tuple()
           |> GenServer.whereis()
  end
end
