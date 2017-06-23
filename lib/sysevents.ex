defmodule Sysevents do
  require Logger
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

  defp validate(
    conn, 
    %{"id" => id, "parent_id" => parent_id, "type" => type}) do
    send_resp(conn, 200, "Success!")
  end

  defp validate(conn, _params) do
    send_resp(conn, 404, "bad_request")
  end

  put "/chain/:event_id" do
    Logger.info "This is the id #{event_id} body id #{conn.body_params["id"]}"
    conn 
    |> validate(conn.body_params)
  end

  get "/chain" do
    Plug.Conn.put_resp_content_type(conn, "application/json")  # TODO REMOVE?
    |> send_resp(200, Poison.encode!(%Event{id: "0123"}))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

end

