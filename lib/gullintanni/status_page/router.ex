defmodule Gullintanni.StatusPage.Router do
  @moduledoc """
  Routes incoming requests for the status page endpoint.
  """

  use Plug.Router
  if Mix.env == :dev, do: use Plug.Debugger
  use Plug.ErrorHandler
  require Logger

  plug Plug.Logger,
    log: :debug

  plug :match
  plug :dispatch

  get "/status" do
    send_resp(conn, 200, "status")
  end

  get "/status/:pipeline" do
    send_resp(conn, 200, "status of pipeline #{pipeline}")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    _ = Logger.debug "Sent #{conn.status}; error raised by Gullintanni.StatusPage.Router"
    send_resp(conn, conn.status, "Something went wrong")
  end
end
