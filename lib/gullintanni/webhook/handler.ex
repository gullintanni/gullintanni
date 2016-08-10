defmodule Gullintanni.Webhook.Handler do
  @moduledoc """
  Handles incoming events from Git providers and CI workers.
  """

  def handle(payload, headers) do
    IO.inspect payload
    IO.inspect headers
  end
end
