defmodule ChippyWeb.PageView do
  use ChippyWeb, :view

  @doc """
  Returns the hour_limit for a particular project.

    iex> Sprint.new([]) |> Sprint.add_project("Foo", "22") |> PageView.hour_limit("Foo")
    22
  """
  def hour_limit(sprint, project_name) do
    sprint.project_limits[project_name]
  end

  @doc """
  Returns true if any projects have been created.

    iex> Sprint.new([]) |> PageView.any_projects?
    false
    iex> Sprint.new([]) |> Sprint.add_project("Foo", "22") |> PageView.any_projects?
    true
  """
  def any_projects?(sprint) do
    sprint.project_allocations != %{}
  end

  @doc """
  Given a map of %{user: number_of_chips, ...}, sum up all the chips and multiply by hours_per_chip

    iex> Sprint.new(["Foo", "Bar"]) \
      |> Sprint.add_chips("Foo", "nmashton", 2) \
      |> Sprint.add_chips("Foo", "vkurup", 3) \
      |> Map.get(:project_allocations) \
      |> Map.get("Foo") \
      |> PageView.total_hours_allocated_to_project
    20  # 5 chips * 4 hours per chip
  """
  def total_hours_allocated_to_project(project_allocation) do
    project_allocation
    |> Map.values()
    |> Enum.sum()
    |> Kernel.*(Application.get_env(:chippy, :hours_per_chip))
  end
end
