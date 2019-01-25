defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def sprint(conn, _params) do
    render(conn, "sprint.html")
  end
end
