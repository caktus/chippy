defmodule ChippyWeb.PageView do
  use ChippyWeb, :view

  def hour_limit(sprint, project_name) do
    sprint.project_limits[project_name]
  end
end
