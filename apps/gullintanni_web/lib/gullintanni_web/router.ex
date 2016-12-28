defmodule GullintanniWeb.Router do
  @moduledoc """
  Routes incoming requests for the status page endpoint.
  """

  use Plug.Router
  if Mix.env == :dev, do: use Plug.Debugger
  use Plug.ErrorHandler
  alias Gullintanni.MergeRequest
  alias Gullintanni.Pipeline
  require EEx
  require Logger

  # the css class and display text for mreq states
  @state_display %{
    :approved => {"success", "Approved"},
    :build_pending => {"info", "Build Pending"},
    :build_passed => {"info", "Build Passed"},
    :build_failed => {"warning", "Build Failed"},
    :error => {"danger", "Error"},
  }

  EEx.function_from_file :defp, :render, "templates/status_page/index.html.eex", [:assigns]
  EEx.function_from_file :defp, :overview, "templates/status_page/_overview.html.eex", [:pipelines]
  EEx.function_from_file :defp, :detail, "templates/status_page/_detail.html.eex", [:pipeline]

  plug Plug.Logger,
    log: :debug

  plug Plug.Static,
    at: "/",
    from: :gullintanni_web,
    only: ["images"]

  plug :match
  plug :dispatch

  get "/" do
    pipelines = list_pipelines()
    title = "Gullintanni Pipelines"

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, render(title: title, pipelines: pipelines))
  end

  get "/:repo_name" do
    with {:ok, pipeline} <- fetch_pipeline("#{repo_name}"),
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

  ## View Helpers

  @spec list_pipelines :: [Pipeline.t]
  defp list_pipelines do
    Gullintanni.Pipeline.Supervisor
    |> Supervisor.which_children
    |> Enum.map(fn {_id, child, _type, _modules} ->
         Agent.get(child, &(&1))
       end)
  end

  @spec fetch_pipeline(String.t) :: {:ok, Pipeline.t} | :error
  defp fetch_pipeline(repo_name) do
    # TODO: This feels inefficient and duplicate repository names will cause an
    # issue for the use case of the overview status page. Perhaps we should
    # store a friendly pipeline "slug" instead?
    result =
      Gullintanni.Pipeline.Supervisor
      |> Supervisor.which_children
      |> Stream.map(fn {_id, child, _type, _modules} ->
           Agent.get(child, &(&1))
         end)
      |> Enum.find(:undefined, fn pipeline ->
           pipeline.repo.name == repo_name
         end)

    case result do
      :undefined -> :error
      pipeline -> {:ok, pipeline}
    end
  end

  @spec count_queued_mreqs(Pipeline.t) :: {non_neg_integer, non_neg_integer}
  defp count_queued_mreqs(%Pipeline{} = pipeline) do
    pipeline.merge_requests
    |> Enum.reduce({0, 0}, fn({_id, mreq}, {queued, total}) ->
         case mreq.state do
           :under_review -> {queued, total + 1}
           _ -> {queued + 1, total + 1}
         end
       end)
  end

  @spec list_under_review_mreqs(Pipeline.t) :: [Pipeline.t]
  defp list_under_review_mreqs(%Pipeline{} = pipeline) do
    pipeline.merge_requests
    |> Map.values
    |> Enum.filter(fn mreq -> mreq.state == :under_review end)
    |> Enum.sort_by(fn mreq -> mreq.id end, &>=/2)
  end

  @spec list_queued_mreqs(Pipeline.t) :: [Pipeline.t]
  defp list_queued_mreqs(%Pipeline{} = pipeline) do
    pipeline.merge_requests
    |> Map.values
    |> Enum.filter(fn mreq -> mreq.state != :under_review end)
    |> Enum.sort_by(fn mreq -> MergeRequest.approved_at(mreq) end)
  end

  defp state_display(state) do
    Map.get(@state_display, state)
  end
end
