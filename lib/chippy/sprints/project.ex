defmodule Chippy.Sprints.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chippy.SprintServer

  schema "projects" do
    field :hour_limit, :integer
    field :name, :string
    field :sprint_name, :string
  end

  def validate_unique_sprint_project(changeset) do
    sprint_name = get_field(changeset, :sprint_name)
    project_name = get_field(changeset, :name)

    if sprint_name && project_name && SprintServer.has_project?(sprint_name, project_name) do
      add_error(changeset, :name, "That project exists already")
    else
      changeset
    end
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :sprint_name, :hour_limit])
    |> update_change(:name, &String.trim/1)
    |> update_change(:sprint_name, &String.trim/1)
    |> validate_required([:name, :sprint_name])
    |> validate_unique_sprint_project()
  end
end
