defmodule SyseventsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  require Sysevents.Eventt
  alias Sysevents.Eventt, as: Eventt
  doctest Sysevents

  @opts Sysevents.init([])


  test "accepts valid put" do
    # Create a test connection
    conn = conn(
      :put, 
      "/chain/123", 
      Poison.encode!(
	%Eventt{parent_id: "321", type: "test_event"}))
	   |> put_req_header("content-type", "application/json")

    # Invoke the plug
    Sysevents.start(conn, @opts)
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

  test "allows put and get" do
    # create a test event
    event_id = Base.encode16(:crypto.hash(:sha256, to_string(:rand.uniform())))
    event = %Eventt{parent_id: "321", type: "test_event"}

    # Create a PUT connection
    conn = conn(:put, "/chain/#{event_id}", Poison.encode!(event))
           |> put_req_header("content-type", "application/json")

    # Invoke the plug
    Sysevents.start(conn, @opts)
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Create a GET connection
    conn = conn(:get, "/chain/#{event_id}")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body)["id"] == event_id
  end
end
