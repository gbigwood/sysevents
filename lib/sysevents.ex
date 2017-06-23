defmodule Sysevents do
  require Logger
  use Plug.Router

  plug :match
  plug :dispatch
  plug Plug.Parsers, parsers: [:json],
    pass:  ["application/json"],
    json_decoder: Poison

  # Tutorial:
  # https://codewords.recurse.com/issues/five/building-a-web-framework-from-scratch-in-elixir

  defmodule Event do
      @derive [Poison.Encoder]
      defstruct [:id]
  end

  put "/chain/:rar" do
    Logger.info "this is the id #{rar}"
    send_resp(conn, 200, "Success!")
  end

  get "/chain" do
    Plug.Conn.put_resp_content_type(conn, "application/json")  # might not need to do this
    |> send_resp(200, Poison.encode!(%Event{id: "0123"}))
  end

  match _ do
        send_resp(conn, 404, "oops")
  end

end
