defmodule Chippy.Sprint do
  defstruct [
    project_allocations: %{},
  ]

  alias Chippy.Sprint

  @doc """
  Creates a new sprint planning session from a list of project
  names `project_names`.
  """
  def new(project_names) do
    project_allocations =
      project_names
      |> Enum.reduce(%{}, fn (name, acc) -> Map.put(acc, name, %{}) end)
    
    %Sprint{
      project_allocations: project_allocations,
    }
  end

  defp add_chip_to_project(project, player_name) do
    Map.update(project, player_name, 1, &(&1 + 1))
  end

  defp remove_chip_from_project(project, player_name) do
    {chips, new_project} = Map.pop(project, player_name)
    case chips do
      1 -> new_project
      nil -> new_project
      _ -> Map.put(new_project, player_name, chips - 1)
    end
  end

  def add_chip(%Sprint{project_allocations: project_allocations} = sprint, project_name, player_name) do
    new_project_allocations =
      project_allocations
      |> Map.update(project_name, %{}, &add_chip_to_project(&1, player_name))
    
      %Sprint{ sprint | project_allocations: new_project_allocations }
  end

  def remove_chip(%Sprint{project_allocations: project_allocations} = sprint, project_name, player_name) do
    new_project_allocations =
      project_allocations
      |> Map.update(project_name, %{}, &remove_chip_from_project(&1, player_name))
    
      %Sprint{ sprint | project_allocations: new_project_allocations }
  end
end