defmodule Gullintanni.Webhook.Router do
  @moduledoc """
  Routes incoming HTTP callbacks from Git providers and CI workers.
  """

  use Plug.Router
  use Plug.ErrorHandler
  alias Gullintanni.Webhook
  require Logger

  plug Plug.Logger,
    log: :debug

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Poison

  plug :match
  plug :dispatch

  post "/webhook" do
    # by this point we should have valid/parsed JSON;
    # handle the JSON payload in the background...
    {:ok, _pid} =
      Task.start(Webhook.EventManager, :sync_notify, [conn])

    # ...so we can send the response immediately
    send_resp(conn, 204, "")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    _ = Logger.debug "Sent #{conn.status}; error raised by Gullintanni.Webhook.Router"
    send_resp(conn, conn.status, "Something went wrong")
  end
end
