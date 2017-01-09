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
        event_type = Event.get_req_header(event, "x-github-event")
        payload = Event.get_payload(event)

        _ = Logger.debug("#{event_type} event received from GitHub")
        handle_event(event_type, payload)
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

  @spec handle_event(String.t, Event.payload) :: :ok
  defp handle_event(type, payload)
  # Merge Requests
  # --------------
  defp handle_event("pull_request", %{"action" => "opened"} = payload) do
    with mreq = GitHub.parse_merge_request(payload["pull_request"]),
         repo = GitHub.parse_repo(payload["repository"]),
         pid <- Pipeline.whereis(repo) do
      Pipeline.handle_mreq_open(pid, mreq)
    end
  end
  defp handle_event("pull_request", %{"action" => "synchronize"} = payload) do
    with mreq = GitHub.parse_merge_request(payload["pull_request"]),
         repo = GitHub.parse_repo(payload["repository"]),
         pid <- Pipeline.whereis(repo) do
      Pipeline.handle_push(pid, mreq.id, mreq.latest_commit)
    end
  end
  defp handle_event("pull_request", %{"action" => "closed"} = payload) do
    with mreq = GitHub.parse_merge_request(payload["pull_request"]),
         repo = GitHub.parse_repo(payload["repository"]),
         pid <- Pipeline.whereis(repo) do
      Pipeline.handle_mreq_close(pid, mreq.id)
    end
  end
  defp handle_event("pull_request", %{"action" => "reopened"} = payload) do
    with mreq = GitHub.parse_merge_request(payload["pull_request"]),
         repo = GitHub.parse_repo(payload["repository"]),
         pid <- Pipeline.whereis(repo) do
      Pipeline.handle_mreq_open(pid, mreq)
    end
  end
  # Comments
  # --------
  # Only handle new comments, not edits.
  defp handle_event("issue_comment", %{"action" => "created"} = payload) do
    with comment <- GitHub.parse_comment(payload),
         repo = GitHub.parse_repo(payload["repository"]),
         pid <- Pipeline.whereis(repo) do
      Pipeline.handle_comment(pid, comment)
    end
  end
  # Catch-all clause
  # ----------------
  defp handle_event(_type, _payload), do: :ok
end
