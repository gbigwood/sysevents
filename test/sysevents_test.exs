defmodule SyseventsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  require Sysevents.Event
  alias Sysevents.Event, as: Event
  doctest Sysevents

  @opts Sysevents.init([])

  test "returns reponse with id" do
    # Create a test connection
    conn = conn(:get, "/chain")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body)["id"] == "0123"
  end


  test "accepts put" do
    # Create a test connection
    conn = conn(:put, "/chain/123", Poison.encode!(%Event{id: "0123"}))
	   |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end
end
