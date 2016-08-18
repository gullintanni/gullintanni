alias Experimental.GenStage

defmodule Gullintanni.Providers.GitHub.EventHandler do
  @moduledoc """
  Receives all webhook broadcasts and handles GitHub-specific requests.
  """

  use GenStage
  alias Gullintanni.Comment
  alias Gullintanni.Pipeline
  alias Gullintanni.Repo
  alias Gullintanni.Webhook.Event
  require Logger

  @provider Gullintanni.Providers.GitHub

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## Callbacks

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Gullintanni.Webhook.EventManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      if from_github?(event) do
        repo = parse_repo(event)
        event_type = Event.get_req_header(event, "x-github-event")
        payload = Event.get_payload(event)

        _ = Logger.debug("#{event_type} event received from repo #{repo}")
        handle_event(event_type, payload, repo)
      end
    end
    {:noreply, [], state}
  end

  @spec from_github?(Event.t) :: boolean
  defp from_github?(event) do
    event
    |> Event.get_req_header("user-agent")
    |> String.starts_with?("GitHub-Hookshot/")

    # TODO: validate X-Hub-Signature header; needs the raw body though, not the
    #       output from Plug.Parsers.JSON. https://developer.github.com/webhooks/securing/#validating-payloads-from-github
  end

  defp parse_repo(event) do
    payload = Event.get_payload(event)
    owner = payload["repository"]["owner"]["login"]
    name = payload["repository"]["name"]

    Repo.new(@provider, owner, name)
  end

  @spec handle_event(String.t, Event.payload, Repo.t) :: :ok
  defp handle_event(type, payload, repo)
  defp handle_event("issue_comment", %{"action" => "created"} = payload, repo) do
    # only respond to new comments, not edits
    with comment <- parse_comment(payload),
         pid <- Pipeline.whereis(repo) do
      Pipeline.handle_comment(pid, comment)
    end
  end

  defp parse_comment(payload) do
    mreq_id = payload["issue"]["number"]
    sender = payload["sender"]["login"]
    body = payload["comment"]["body"]
    timestamp = payload["comment"]["created_at"] |> NaiveDateTime.from_iso8601!

    Comment.new(mreq_id, sender, body, timestamp)
  end
end
