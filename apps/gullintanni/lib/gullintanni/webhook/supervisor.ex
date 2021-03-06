defmodule Gullintanni.Webhook.Supervisor do
  @moduledoc """
  Supervises the Gullintanni webhook processes.
  """

  use Supervisor

  alias Gullintanni.Config
  alias Gullintanni.Providers
  alias Gullintanni.Webhook

  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children =
      default_workers() ++ http_workers()

    supervise(children, strategy: :one_for_one)
  end

  defp default_workers() do
    [
      worker(Webhook.EventManager, []),
      worker(Providers.GitHub.EventHandler, []),
    ]
  end

  defp http_workers do
    with true <- Config.load(:enable_http_workers) do
      [webhook_router()]
    else
      _ -> []
    end
  end

  defp webhook_router do
    bind_ip = Application.fetch_env!(:gullintanni, :bind_ip)
    bind_port = Application.fetch_env!(:gullintanni, :bind_port)
    cowboy_opts =
      case SocketAddress.new(bind_ip, bind_port) do
        {:ok, socket} ->
          _ = Logger.info "started listening on #{socket}/webhook"
          SocketAddress.to_opts(socket)
        {:error, :invalid_ip} ->
          raise ArgumentError, "invalid :bind_ip configuration setting"
        {:error, :invalid_port} ->
          raise ArgumentError, "invalid :bind_port configuration setting"
      end

    Plug.Adapters.Cowboy.child_spec(:http, Gullintanni.Webhook.Router, [], cowboy_opts)
  end
end
