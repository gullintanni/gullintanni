defmodule GullintanniWeb do
  @moduledoc """
  The Gullintanni Web frontend application.
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = http_workers()

    opts = [strategy: :one_for_one, name: GullintanniWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_workers() do
    if Application.get_env(:gullintanni_web, :enable_http_workers) do
      [gullintanni_web_router()]
    else
      []
    end
  end

  defp gullintanni_web_router do
    bind_ip = Application.fetch_env!(:gullintanni_web, :bind_ip)
    bind_port = Application.fetch_env!(:gullintanni_web, :bind_port)
    cowboy_opts =
      case SocketAddress.new(bind_ip, bind_port) do
        {:ok, socket} ->
          _ = Logger.info "started listening on #{socket}"
          [ip: socket.ip, port: socket.port]
        {:error, :invalid_ip} ->
          raise ArgumentError, "invalid :bind_ip configuration setting"
        {:error, :invalid_port} ->
          raise ArgumentError, "invalid :bind_port configuration setting"
      end

    Plug.Adapters.Cowboy.child_spec(:http, GullintanniWeb.Router, [], cowboy_opts)
  end
end
