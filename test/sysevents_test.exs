defmodule SyseventsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Sysevents

  @opts Sysevents.init([])

  test "returns 200 ok on get" do
    # Create a test connection
    conn = conn(:get, "/chain")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end
end
