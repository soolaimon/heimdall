defmodule HeimdallWeb.ApiController do
  use HeimdallWeb, :controller
  import Plug.Conn
  require Integer


  # this route takes one upc, and returns the upc with the check digit added
  # http://0.0.0.0:4000/api/add_check_digit/1234
  def add_check_digit(conn, params) do
    check_digit_with_upc = _calculate_check_digit(params["upc"])
    _send_json(conn, 200, %{upc: check_digit_with_upc})
  end

  # this route takes a comma separated list and should add a check digit to each element
  # http://0.0.0.0:4000/api/add_a_bunch_of_check_digits/12345,233454,34341432
  def add_a_bunch_of_check_digits(conn, params) do
    check_digits_with_upc = String.split(params["upcs"], ",")
    |> Enum.map((fn upc -> _calculate_check_digit(upc) end))
    _send_json(conn, 200, %{upcs: check_digits_with_upc})
  end

  # these are private methods
  defp _calculate_check_digit(upc) do
    upc_list = _convert_upc(upc)
    evens_sum = Enum.sum(_filter_by_index(upc_list, &Integer.is_even/1))
    odds_sum = Enum.sum(_filter_by_index(upc_list, &Integer.is_odd/1))
    remainder = rem((evens_sum + (odds_sum * 3)), 10)
    
    Enum.join(upc_list ++ [_check_by_remainder(remainder)])
  end

  defp _check_by_remainder(0), do: 0
  defp _check_by_remainder(remainder) do
    10 - remainder
  end

  defp _filter_by_index(nums, filter_func) do
    nums 
    |> Enum.with_index
    |> Enum.filter(fn { _, index } -> filter_func.(index + 1) end)
    |> Enum.map(fn { el, _ } -> el end)
  end

  defp _convert_upc(str) do
    str
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  
  # this is a thing to format your responses and return json to the client
  defp _send_json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Poison.encode!(body))
  end
end
