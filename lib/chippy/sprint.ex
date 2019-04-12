defmodule Chippy.Sprint do
  @derive Jason.Encoder
  defstruct project_allocations: %{}

  alias Chippy.Sprint

  @doc """
  Creates a new sprint planning session from a list of project
  names `project_names`.
  """
  def new(project_names) do
    project_allocations =
      project_names
      |> Enum.reduce(%{}, fn name, acc -> Map.put(acc, name, %{}) end)

    %Sprint{
      project_allocations: project_allocations
    }
  end

  @doc """
  Adds a new empty project to a sprint.

    iex> Sprint.new([]) |> Sprint.add_project("Foo")
    %Sprint{project_allocations: %{"Foo" => %{}}}
  """
  def add_project(sprint, project_name) do
    %Sprint{
      project_allocations: Map.put(sprint.project_allocations, project_name, %{})
    }
  end

  def has_project?(%Sprint{project_allocations: project_allocations}, project_name) do
    Map.has_key?(project_allocations, project_name)
  end

  def sorted_allocations(sprint) do
    sprint.project_allocations
    |> Map.to_list()
    |> Enum.sort_by(fn {k, v} -> k end)
  end

  defp add_chips_to_project(project, person_name, chip_count) do
    Map.update(project, person_name, chip_count, &(&1 + chip_count))
  end

  defp remove_chips_from_project(project, person_name, chip_count) do
    {chips, new_project} = Map.pop(project, person_name)

    cond do
      nil == chips -> new_project
      chips <= chip_count -> new_project
      true -> Map.put(new_project, person_name, chips - chip_count)
    end
  end

  @doc """
  Adds chips to a user's project allocation on a sprint.

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chips("Foo", "nmashton", 3)
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{"nmashton" => 3}}}
  """
  def add_chips(
        %Sprint{project_allocations: project_allocations} = sprint,
        project_name,
        person_name,
        chip_count
      ) do
    new_project_allocations =
      project_allocations
      |> Map.update(
        project_name,
        %{person_name => chip_count},
        &add_chips_to_project(&1, person_name, chip_count)
      )

    %Sprint{sprint | project_allocations: new_project_allocations}
  end

  @doc """
  Removes chips from a user's project allocation. If there are too few chips,
  remove the user altogether.

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chips("Foo", "nmashton", 3) \
      |> Sprint.remove_chips("Foo", "nmashton", 2)
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{"nmashton" => 1}}}


    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chips("Foo", "nmashton", 3) \
      |> Sprint.remove_chips("Foo", "nmashton", 3)
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{}}}

    # if they're not there, doesn't matter
    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.remove_chips("Foo", "nmashton", 1_024)
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{}}}
  """
  def remove_chips(
        %Sprint{project_allocations: project_allocations} = sprint,
        project_name,
        person_name,
        chip_count
      ) do
    new_project_allocations =
      project_allocations
      |> Map.update(project_name, %{}, &remove_chips_from_project(&1, person_name, chip_count))

    %Sprint{sprint | project_allocations: new_project_allocations}
  end

  def merge_alloc_fragments(alloc1, alloc2) do
    Map.merge(
      alloc1,
      alloc2,
      fn _k, proj1, proj2 ->
        Map.merge(
          proj1,
          proj2,
          fn _k, v1, v2 -> v1 + v2 end
        )
      end
    )
  end

  def merge_allocs_for_project({project_name, project_allocs}, allocs_by_person) do
    project_allocs_by_person =
      project_allocs
      |> Enum.map(fn {person_name, count} -> %{person_name => %{project_name => count}} end)

    Enum.reduce(
      project_allocs_by_person,
      allocs_by_person,
      &Sprint.merge_alloc_fragments/2
    )
  end

  @doc """
  Turns the project allocations map "inside out" so that we can
  easily display chips user by user.

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chips("Foo", "nmashton", 2) \
      |> Sprint.add_chips("Foo", "vkurup", 3) \
      |> Sprint.add_chips("Bar", "vkurup", 1) \
      |> Sprint.display_by_users
    %{"vkurup" => %{"Bar" => 1, "Foo" => 3}, "nmashton" => %{"Foo" => 2}}
  """
  def display_by_users(sprint) do
    sprint.project_allocations
    |> Enum.reduce(
      %{},
      &Sprint.merge_allocs_for_project/2
    )
  end

  @doc """
  Returns the users and their total chips placed in the sprint.

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chips("Foo", "nmashton", 2) \
      |> Sprint.add_chips("Foo", "vkurup", 3) \
      |> Sprint.add_chips("Bar", "vkurup", 1) \
      |> Sprint.user_chip_counts
    [{"nmashton", 2}, {"vkurup", 4}]
  """
  def user_chip_counts(sprint) do
    for {user, projects} <- Sprint.display_by_users(sprint) do
      {user,
       projects
       |> Map.values()
       |> Enum.sum()}
    end
    |> Enum.sort()
  end

  @doc """
  Returns the projects for a sprint, sorted alphabetically.

    iex> Sprint.new(["Foo", "Bar"]) |> Sprint.display_projects
    ["Bar", "Foo"]
  """
  def display_projects(sprint) do
    sprint.project_allocations
    |> Enum.map(fn {project_name, _} -> project_name end)
    |> Enum.sort()
  end
end
