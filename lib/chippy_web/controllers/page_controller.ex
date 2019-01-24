defmodule ChippyWeb.PageController do
  use ChippyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
