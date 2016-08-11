alias Experimental.GenStage

defmodule Gullintanni.Providers.GitHub.EventHandler do
  @moduledoc """
  """

  use GenStage
  alias Gullintanni.Webhook

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  ## Callbacks

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Webhook.EventManager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect event
    end
    {:noreply, [], state}
  end
end
