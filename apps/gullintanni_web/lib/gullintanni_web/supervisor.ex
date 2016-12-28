defmodule GullintanniWeb.Supervisor do
  @moduledoc """
  Supervises the Gullintanni status page processes.
  """

  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: StatusPage.Supervisor)
  end

  def init(_) do
    enabled = Application.get_env(:gullintanni, :enable_http_workers, false)
    children = case enabled do
      true -> [status_page_router()]
      false -> []
    end

    supervise(children, strategy: :one_for_one)
  end

  defp status_page_router do
    config = Application.get_env(:gullintanni_web, :status_page)
    cowboy_opts =
      case Socket.new(config[:bind_ip], config[:bind_port]) do
        {:ok, socket} ->
          _ = Logger.info "started listening on #{socket}"
          [ip: socket.ip, port: socket.port]
        {:error, :invalid_ip_address} ->
          raise ArgumentError, "invalid :status_page, :bind_ip configuration setting"
        {:error, :invalid_port} ->
          raise ArgumentError, "invalid :status_page, :bind_port configuration setting"
      end

    Plug.Adapters.Cowboy.child_spec(:http, GullintanniWeb.Router, [], cowboy_opts)
  end
end
