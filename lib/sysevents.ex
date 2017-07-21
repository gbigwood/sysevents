defmodule Sysevents do
  use Plug.Router
  use Application
  require Ecto.Query

  plug Plug.Logger
  # TODO look into: Plug.RequestId - sets up a request ID to be used in logs;
  plug :match
  plug Plug.Parsers, parsers: [:json],
    pass:  ["application/json"],
    json_decoder: Poison
  plug :dispatch

  defmodule Link do
      @derive [Poison.Encoder]
      defstruct [:id, :parent_id, :type]
  end

  get "/" do
    send_resp(conn, 200, "ok")
  end

  put "/link/:event_id" do
    conn 
    |> process(event_id, conn.body_params)
  end

  get "/link/:event_id" do
    case Event |> Sysevents.Repo.get_by(event_id: event_id) do
      nil ->
        Plug.Conn.put_resp_content_type(conn, "text/plain") 
        |> send_resp(404, "Unknown link #{event_id}")
      event ->
        Plug.Conn.put_resp_content_type(conn, "application/json") 
        |> send_resp(200, Poison.encode!(
          %Link{id: event.event_id, parent_id: event.parent_id, type: event.type}))
    end
  end

  get "/chain/:event_id" do
    case get_chain(event_id, []) do
      [] -> 
        Plug.Conn.put_resp_content_type(conn, "text/plain") 
        |> send_resp(404, "Unknown link #{event_id}")
      chain ->
        Plug.Conn.put_resp_content_type(conn, "application/json") 
        |> send_resp(200, Poison.encode!(chain)) # |> Enum.reverse if wanted
    end
  end

  defp get_chain(event_id, accumulator) do
    case get_link_from_db(event_id) do
      nil -> accumulator
      link-> get_chain(link.parent_id, [link | accumulator])
    end
  end

  defp get_link_from_db(event_id) do
    case Event |> Sysevents.Repo.get_by(event_id: event_id) do
      nil -> nil
      event -> %Link{id: event.event_id, parent_id: event.parent_id, type: event.type}
    end
  end

  match _ do
    send_resp(conn, 404, "Unknown request type")
  end

  defp process(conn, event_id, %{"parent_id" => parent_id, "type" => type}) do
    Sysevents.Repo.insert!(%Event{event_id: event_id, parent_id: parent_id, type: type})
    send_resp(conn, 200, "Success!")
  end

  defp process(conn, _event_id, _params) do
    send_resp(conn, 404, "bad_request")
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(Sysevents.Repo, []),
      worker(__MODULE__, [], function: :main),
    ]
    opts = [strategy: :one_for_one, name: Sysevents.Supervisor]
    IO.puts "Starting application"
    Supervisor.start_link(children, opts)
  end

  def main do
    port_str = System.get_env("PORT") || "4000"
    port = String.to_integer(port_str)
    IO.puts "received port: #{port_str}"
    {:ok, _} = Plug.Adapters.Cowboy.http Sysevents, [], port: port
  end
end
