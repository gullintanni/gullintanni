defmodule Gullintanni.Webhook.Router do
  @moduledoc """
  Routes incoming HTTP callbacks from Git providers and CI workers.
  """

  use Plug.Router

  plug Plug.Logger,
    log: :debug

  plug :match
  plug :dispatch

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Poison

  post "/webhook" do
    send_resp(conn, 204, "")
  end

  match _ do
    send_resp(conn, 404, "Not Found") |> halt
  end
end
