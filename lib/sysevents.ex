defmodule Sysevents do
  use Plug.Router
  use Application

  plug Plug.Logger
  # TODO look into: Plug.RequestId - sets up a request ID to be used in logs;
  plug :match
  plug Plug.Parsers, parsers: [:json],
    pass:  ["application/json"],
    json_decoder: Poison
  plug :dispatch

  defmodule Eventt do
      @derive [Poison.Encoder]
      defstruct [:id, :parent_id, :type]
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Sysevents.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Sysevents.Supervisor]
    Supervisor.start_link(children, opts)
  end

  put "/chain/:event_id" do
    conn 
    |> process(event_id, conn.body_params)
  end

  require Ecto.Query
  get "/chain/:event_id" do
    case Event |> Sysevents.Repo.get_by(event_id: event_id) do
      nil ->
        Plug.Conn.put_resp_content_type(conn, "application/json") 
        |> send_resp(200, Poison.encode!(%Eventt{id: "0123"}))
      event ->
        Plug.Conn.put_resp_content_type(conn, "application/json") 
        |> send_resp(200, Poison.encode!(%Eventt{id: event.event_id, parent_id: event.parent_id, type: event.type}))
    end
  end

  match _ do
    send_resp(conn, 404, "Unknown request type")
  end

  defp process(conn, event_id,
                %{"parent_id" => parent_id, "type" => type} = params) do
    Sysevents.Repo.insert!(%Event{event_id: event_id, parent_id: parent_id, type: type})
    send_resp(conn, 200, "Success!")
  end

  defp process(conn, _event_id, _params) do
    send_resp(conn, 404, "bad_request")
  end
end
