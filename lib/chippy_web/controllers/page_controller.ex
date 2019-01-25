defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller

  alias Chippy.Sprint

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # NOTE: pretty much immediately I'm going to want to replace
  # this with a React view, now that I'm thinking about it ...
  def sprint(conn, _params) do
    fake_sprint =
      Sprint.new(["SAM", "Mind My Health", "Moda"])
      |> Sprint.add_chips("SAM", "nmashton", 5)
      |> Sprint.add_chips("Mind My Health", "nmashton", 3)
      |> Sprint.add_chips("Moda", "vkurup", 4)
      |> Sprint.add_chips("SAM", "vkurup", 8)
      |> Sprint.add_chips("Moda", "daaray", 6)

    by_user = Sprint.display_by_users(fake_sprint)

    project_list = Sprint.display_projects(fake_sprint)

    conn
    |> assign(:by_user, by_user)
    |> assign(:project_list, project_list)
    |> render("sprint.html")
  end
end
