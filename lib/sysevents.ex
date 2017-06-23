defmodule Sysevents do
  use Plug.Router
  plug Plug.Logger
  # TODO look into: Plug.RequestId - sets up a request ID to be used in logs;

  plug :match
  plug Plug.Parsers, parsers: [:json],
    pass:  ["application/json"],
    json_decoder: Poison
  plug :dispatch

  defmodule Event do
      @derive [Poison.Encoder]
      defstruct [:id, :parent_id, :type]
  end

  put "/chain/:event_id" do
    conn 
    |> process(event_id, conn.body_params)
  end

  get "/chain" do
    Plug.Conn.put_resp_content_type(conn, "application/json")  # TODO REMOVE?
    |> send_resp(200, Poison.encode!(%Event{id: "0123"}))  # TODO more fields plz
  end

  match _ do
    send_resp(conn, 404, "unkown request type")
  end

  defp process(conn, event_id,
                %{"parent_id" => parent_id, "type" => type} = params) do
    # TODO Store the entry
    send_resp(conn, 200, "Success!")
  end

  defp process(conn, _event_id, _params) do
    send_resp(conn, 404, "bad_request")
  end
end
