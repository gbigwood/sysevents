defmodule Sysevents do
  require Logger
  import Plug.Conn
  # plug Plug.Parsers, parsers: [:urlencoded, :json],
  # pass:  ["text/*"],
  # json_decoder: Poison


  # Tutorial:
  # https://codewords.recurse.com/issues/five/building-a-web-framework-from-scratch-in-elixir

  defmodule Event do
      @derive [Poison.Encoder]
      defstruct [:id]
  end


  def init(default_opts) do
    Logger.info "starting up"
  end

  def call(conn, _opts) do
    route(conn.method, conn.path_info, conn)
  end

  def route("PUT", ["event"], conn) do
    # put a chain
    conn 
    |> send_resp(200, "you put: #{conn.body_params["id"]}")
  end

  def route("GET", ["chain", event_id], conn) do
    # this route is for /chain/event_id
    conn 
    |> put_resp_content_type("application/json") 
    |> send_resp(200, Poison.encode!(%Event{id: "#{event_id}"}))
  end

  def route(_method, _path, conn) do
    # this route is called if no other routes match
    conn |> send_resp(404, "Couldn't find that page, sorry!")
  end

end
