defmodule ChippyWeb.PageControllerTest do
  use ChippyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Chippy!"
  end
end
