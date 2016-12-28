defmodule Gullintanni.Webhook.Event do
  @moduledoc """
  Utility module for extracting information from webhook events.
  """

  @typedoc "The payload of an event"
  @type payload :: map

  @typedoc "The event type"
  @type t :: Plug.Conn.t

  @doc """
  Returns the value of the request header specified by `key`.

  Returns `nil` if the header was not found.
  """
  @spec get_req_header(t, String.t) :: String.t | nil
  def get_req_header(%Plug.Conn{} = event, key) when is_binary(key) do
    case Plug.Conn.get_req_header(event, key) do
      [value] -> value
      [] -> nil
    end
  end

  @doc """
  Returns the payload from the `event`.
  """
  @spec get_payload(t) :: payload
  def get_payload(%Plug.Conn{} = event), do: event.body_params
end
