defmodule SyseventsTest do
  use ExUnit.Case, async: true
  use Plug.Test
  require Sysevents.Link
  alias Sysevents.Link, as: Link
  doctest Sysevents

  @opts Sysevents.init([])

  test "accepts valid put" do
    put_link(123, %Link{parent_id: "321", type: "test_event"}) 
  end

  test "rejects put with missing parent" do
    # Create a test connection
    conn = conn(
      :put, 
      "/link/123", 
      Poison.encode!(
	%{"type" => "test_event"}))
	   |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end


  test "rejects get for missing link" do
    # Create a test connection
    event_id = Base.encode16(:crypto.hash(:sha256, to_string(:rand.uniform())))

    # Create a GET connection
    conn = conn(:get, "/link/#{event_id}")

    # Invoke the plug
    Sysevents.start(conn, @opts)
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "allows put and get" do
    # create a test event
    event_id = Base.encode16(:crypto.hash(:sha256, to_string(:rand.uniform())))
    event = %Link{parent_id: "321", type: "test_event"}

    put_link(event_id, event)

    # Create a GET connection
    conn = conn(:get, "/link/#{event_id}")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body)["id"] == event_id
    assert Poison.decode!(conn.resp_body)["parent_id"] == "321"
    assert Poison.decode!(conn.resp_body)["type"] == "test_event"
  end

  test "allows put and get of chain" do
    # create test events
    event_id0 = Base.encode16(:crypto.hash(:sha256, to_string(:rand.uniform())))
    event0 = %Link{parent_id: "321", type: "test_event"}

    event_id1 = Base.encode16(:crypto.hash(:sha256, to_string(:rand.uniform())))
    event1 = %Link{parent_id: event_id0, type: "test_event"}

    put_link(event_id0, event0)
    put_link(event_id1, event1)

    conn = get_chain(event_id1)

    assert Poison.decode!(conn.resp_body)["id"] == event_id1
    assert Poison.decode!(conn.resp_body)["parent_id"] == event_id0
    assert Poison.decode!(conn.resp_body)["type"] == "test_event"
  end

  defp put_link(event_id, event) do
    # Create a PUT connection
    conn = conn(:put, "/link/#{event_id}", Poison.encode!(event))
           |> put_req_header("content-type", "application/json")

    # Invoke the plug
    Sysevents.start(conn, @opts)
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end

  defp get_chain(event_id) do
    # Create a GET connection
    conn = conn(:get, "/chain/#{event_id}")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    conn
  end
end
