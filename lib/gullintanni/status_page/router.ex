defmodule Gullintanni.StatusPage.Router do
  @moduledoc """
  Routes incoming requests for the status page endpoint.
  """

  use Plug.Router
  if Mix.env == :dev, do: use Plug.Debugger
  use Plug.ErrorHandler
  alias Gullintanni.Pipeline
  require EEx
  require Logger

  EEx.function_from_file :defp, :render, "templates/status_page/index.html.eex", [:assigns]
  EEx.function_from_file :defp, :overview, "templates/status_page/_overview.html.eex", [:pipelines]
  EEx.function_from_file :defp, :detail, "templates/status_page/_detail.html.eex", [:pipeline]

  plug Plug.Logger,
    log: :debug

  plug :match
  plug :dispatch

  get "/status" do
    pipelines = Pipeline.get_all()
    title = "Gullintanni Pipelines"

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render(title: title, pipelines: pipelines))
  end

  get "/status/:repo_name" do
    with {:ok, pipeline} <- Pipeline.fetch_repo("#{repo_name}"),
         title = "Pipeline #{pipeline.repo} - Gullintanni" do
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, render(title: title, pipeline: pipeline))
    else
      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    _ = Logger.debug "Sent #{conn.status}; error raised by Gullintanni.StatusPage.Router"
    send_resp(conn, conn.status, "Something went wrong")
  end
end
