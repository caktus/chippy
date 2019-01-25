defmodule Chippy.Sprint do
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

  defp add_chip_to_project(project, person_name) do
    Map.update(project, person_name, 1, &(&1 + 1))
  end

  defp remove_chip_from_project(project, person_name) do
    {chips, new_project} = Map.pop(project, person_name)

    case chips do
      1 -> new_project
      nil -> new_project
      _ -> Map.put(new_project, person_name, chips - 1)
    end
  end

  @doc """
  Adds a chip to a user's project allocation on a sprint.

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chip("Foo", "nmashton")
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{"nmashton" => 1}}}
  """
  def add_chip(
        %Sprint{project_allocations: project_allocations} = sprint,
        project_name,
        person_name
      ) do
    new_project_allocations =
      project_allocations
      |> Map.update(project_name, %{}, &add_chip_to_project(&1, person_name))

    %Sprint{sprint | project_allocations: new_project_allocations}
  end

  @doc """
  Removes a chip from a user's project allocation. If there are no chips
  left, removes them altogether.

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chip("Foo", "nmashton") \
      |> Sprint.add_chip("Foo", "nmashton") \
      |> Sprint.remove_chip("Foo", "nmashton")
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{"nmashton" => 1}}}


    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chip("Foo", "nmashton") \
      |> Sprint.add_chip("Foo", "nmashton") \
      |> Sprint.remove_chip("Foo", "nmashton") \
      |> Sprint.remove_chip("Foo", "nmashton")
    %Sprint{project_allocations: %{"Bar" => %{}, "Foo" => %{}}}
  """
  def remove_chip(
        %Sprint{project_allocations: project_allocations} = sprint,
        project_name,
        person_name
      ) do
    new_project_allocations =
      project_allocations
      |> Map.update(project_name, %{}, &remove_chip_from_project(&1, person_name))

    %Sprint{sprint | project_allocations: new_project_allocations}
  end

  def merge_alloc_fragments(alloc1, alloc2) do
    Map.merge(
      alloc1,
      alloc2,
      fn (_k, proj1, proj2) ->
        Map.merge(
          proj1,
          proj2,
          fn (_k, v1, v2) -> v1 + v2 end
          )
        end
      )
  end

  def merge_allocs_for_project({project_name, project_allocs}, allocs_by_person) do
    project_allocs_by_person =
      project_allocs
      |> Enum.map(fn({person_name, count}) -> %{person_name => %{project_name => count}} end)
    
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
      |> Sprint.add_chip("Foo", "nmashton") \
      |> Sprint.add_chip("Foo", "vkurup") \
      |> Sprint.add_chip("Bar", "vkurup") \
      |> Sprint.add_chip("Foo", "nmashton") \
      |> Sprint.display_by_users
    %{"vkurup" => %{"Bar" => 1, "Foo" => 1}, "nmashton" => %{"Foo" => 2}}
  """
  def display_by_users(sprint) do
    sprint.project_allocations
      |> Enum.reduce(
        %{},
        &Sprint.merge_allocs_for_project/2
      )
  end
end
