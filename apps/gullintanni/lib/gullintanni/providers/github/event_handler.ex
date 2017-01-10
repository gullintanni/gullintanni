alias Experimental.GenStage

defmodule Gullintanni.Providers.GitHub.EventHandler do
  @moduledoc """
  Receives all webhook broadcasts and handles GitHub-specific requests.
  """

  use GenStage

  alias Gullintanni.Pipeline
  alias Gullintanni.Providers.GitHub
  alias Gullintanni.Webhook.Event

  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## GenStage Callbacks

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Gullintanni.Webhook.EventManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      if from_github?(event) do
        payload = Event.get_payload(event)
        type = Event.get_req_header(event, "x-github-event")
        action = Map.get(payload, "action")
        repo = GitHub.parse_repo(payload["repository"])

        _ = Logger.debug("#{type} event received from GitHub")
        handle_event(type, action, repo, payload)
      end
    end
    {:noreply, [], state}
  end

  ## GitHub-specific handling

  @spec from_github?(Event.t) :: boolean
  defp from_github?(event) do
    event
    |> Event.get_req_header("user-agent")
    |> String.starts_with?("GitHub-Hookshot/")

    # TODO: validate X-Hub-Signature header; needs the raw body though, not the
    #       output from Plug.Parsers.JSON. https://developer.github.com/webhooks/securing/#validating-payloads-from-github
  end

  @spec handle_event(String.t, String.t, Repo.t, Event.payload) :: :ok
  defp handle_event(type, action, repo, payload)
  # Merge Requests
  # --------------
  defp handle_event("pull_request", action, repo, payload) do
    merge_req = GitHub.parse_merge_request(payload["pull_request"])

    case action do
      "opened" ->
        Pipeline.handle_merge_request_open(repo, merge_req)
      "synchronize" ->
        Pipeline.handle_push(repo, merge_req.id, merge_req.latest_commit)
      "closed" ->
        Pipeline.handle_merge_request_close(repo, merge_req.id)
      "reopened" ->
        Pipeline.handle_merge_request_open(repo, merge_req)
      _ ->
        :ok
    end
  end
  # Comments
  # --------
  defp handle_event("issue_comment", action, repo, payload) do
    comment = GitHub.parse_comment(payload)

    # Only handle new comments, not edits.
    case action do
      "created" ->
        Pipeline.handle_comment(repo, comment)
      _ ->
        :ok
    end
  end
  # Catch-all clause
  # ----------------
  defp handle_event(_type, _action, _payload, _repo), do: :ok
end
