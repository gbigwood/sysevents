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
    event_id = uuid()

    # Create a GET connection
    conn = conn(:get, "/link/#{event_id}")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end


  test "rejects get for missing chain" do
    # Create a test connection
    event_id = uuid()

    # Create a GET connection
    conn = conn(:get, "/chain/#{event_id}")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "allows put and get" do
    # create a test event
    event_id = uuid()
    event = %Link{parent_id: "321", type: "test_event"}

    put_link(event_id, event)

    result = Poison.decode!(get_link(event_id).resp_body)

    assert result["id"] == event_id
    assert result["parent_id"] == "321"
    assert result["type"] == "test_event"
  end

  test "get of chain with multiple links" do
    # create test events
    event_id0 = uuid()
    event0 = %Link{parent_id: "321", type: "test_event"}

    event_id1 = uuid()
    event1 = %Link{parent_id: event_id0, type: "test_event"}

    put_link(event_id0, event0)
    put_link(event_id1, event1)

    result = Poison.decode!(get_chain(event_id1).resp_body)
    # TODO could refactor into a neater pattern match?
    [first | tail] = result
    assert first["id"] == event_id0
    assert first["parent_id"] == "321"

    [second | _] = tail
    assert second["id"] == event_id1
    assert second["parent_id"] == event_id0
  end

  test "get entire chain from middle" do
    # create test events
    event_id0 = uuid()
    event0 = %Link{parent_id: "321", type: "test_event"}

    event_id1 = uuid()
    event1 = %Link{parent_id: event_id0, type: "test_event"}

    event_id2 = uuid()
    event2 = %Link{parent_id: event_id1, type: "test_event"}

    event_id3 = uuid()
    event3 = %Link{parent_id: event_id2, type: "test_event"}

    put_link(event_id0, event0)
    put_link(event_id1, event1)
    put_link(event_id2, event2)
    put_link(event_id3, event3)

    result = Poison.decode!(get_chain(event_id1).resp_body)

    # TODO could refactor into a neater pattern match?
    [first | tail] = result
    assert first["id"] == event_id0
    assert first["parent_id"] == "321"

    [second | tail] = tail
    assert second["id"] == event_id1
    assert second["parent_id"] == event_id0

    [third | tail] = tail
    assert third["id"] == event_id2
    assert third["parent_id"] == event_id1

    [fourth | _] = tail
    assert fourth["id"] == event_id3
    assert fourth["parent_id"] == event_id2
  end

  test "get tree chain from middle" do
    # create test events
    event_id0 = uuid()
    event0 = %Link{parent_id: "321", type: "test_event"}

    event_id1 = uuid()
    event1 = %Link{parent_id: event_id0, type: "test_event"}

    event_id2 = uuid()
    event2 = %Link{parent_id: event_id0, type: "test_event"}

    event_id3 = uuid()
    event3 = %Link{parent_id: event_id2, type: "test_event"}

    put_link(event_id0, event0)
    put_link(event_id1, event1)
    put_link(event_id2, event2)
    put_link(event_id3, event3)

    result = Poison.decode!(get_chain(event_id1).resp_body)

    [first | tail] = result
    assert first["id"] == event_id0
    assert first["parent_id"] == "321"

    [second | tail] = tail
    assert second["id"] == event_id1
    assert second["parent_id"] == event_id0

    [third | tail] = tail
    assert third["id"] == event_id2
    assert third["parent_id"] == event_id0

    [fourth | _] = tail
    assert fourth["id"] == event_id3
    assert fourth["parent_id"] == event_id2
  end


  defp put_link(event_id, event) do
    # Create a PUT connection
    conn = conn(:put, "/link/#{event_id}", Poison.encode!(event))
           |> put_req_header("content-type", "application/json")

    # Invoke the plug
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

  defp get_link(event_id) do
    # Create a GET connection
    conn = conn(:get, "/link/#{event_id}")

    # Invoke the plug
    conn = Sysevents.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    conn
  end

  defp uuid() do
    Base.encode16(:crypto.hash(:sha256, to_string(:rand.uniform())))
  end
end
