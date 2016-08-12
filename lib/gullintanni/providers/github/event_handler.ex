alias Experimental.GenStage

defmodule Gullintanni.Providers.GitHub.EventHandler do
  @moduledoc """
  Receives all webhook broadcasts and handles GitHub-specific requests.
  """

  use GenStage
  alias Gullintanni.Repo
  alias Gullintanni.Webhook.Event
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  ## Callbacks

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Gullintanni.Webhook.EventManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      with true <- from_github?(event),
           repo <- parse_repo(event) do
        _ = Logger.debug "Event received from GitHub repo #{repo}"
      end
    end
    {:noreply, [], state}
  end

  # Returns `true` if the connection came from GitHub, otherwise `false`.
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
    owner = payload["repository"]["name"]
    name = payload["repository"]["owner"]["login"]

    Repo.new(owner, name)
  end
end
