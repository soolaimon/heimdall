defmodule HeimdallWeb.ApiControllerTest do
  use HeimdallWeb.ConnCase

  test "GET /add_check_digit", %{conn: conn} do
    conn = get conn, "/api/add_check_digit/72641217542"
    assert json_response(conn, 200) =~ "726412175425"

    conn = get conn, "/api/add_check_digit/69277198116"
    assert json_response(conn, 200) =~ "692771981161"
  end
end
