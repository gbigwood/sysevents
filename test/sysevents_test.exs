defmodule SyseventsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  require Sysevents.Eventt
  alias Sysevents.Eventt, as: Eventt
  doctest Sysevents

  @opts Sysevents.init([])

  test "returns reponse with id" do
    # Create a test connection
    conn = conn(:get, "/chain")

    # Invoke the plug
    Sysevents.start(conn, @opts)
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body)["id"] == "0123"
  end

  test "accepts valid put" do
    # Create a test connection
    conn = conn(
      :put, 
      "/chain/123", 
      Poison.encode!(
	%Eventt{parent_id: "321", type: "test_event"}))
	   |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "rejects put with missing parent" do
    # Create a test connection
    conn = conn(
      :put, 
      "/chain/123", 
      Poison.encode!(
	%{"type" => "test_event"}))
	   |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end
end
