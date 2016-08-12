defmodule Gullintanni do
  @moduledoc """
  The Gullintanni Git merge bot application.
  """

  use Application
  import Supervisor.Spec, warn: false
  alias Gullintanni.Socket

  def start(_type, _args) do
    children =
      default_workers() ++ http_workers()

    opts = [strategy: :one_for_one, name: Gullintanni.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp default_workers do
    # TODO: figure out an appropriate supervisor tree
    [worker(Gullintanni.Webhook.EventManager, []),
     worker(Gullintanni.Providers.GitHub.EventHandler, [])]
  end

  defp http_workers do
    if Application.get_env(:gullintanni, :enable_http_workers),
      do: [webhook_worker()],
      else: []
  end

  defp webhook_worker do
    config = Application.get_env(:gullintanni, :webhook)
    cowboy_opts =
      case Socket.new(config[:bind_ip], config[:bind_port]) do
        {:ok, socket} ->
          [ip: socket.ip, port: socket.port]
        {:error, :invalid_ip_address} ->
          raise ArgumentError, "invalid :webhook, :bind_ip configuration setting"
        {:error, :invalid_port} ->
          raise ArgumentError, "invalid :webhook, :bind_port configuration setting"
      end

    Plug.Adapters.Cowboy.child_spec(:http, Gullintanni.Webhook.Router, [], cowboy_opts)
  end
end
