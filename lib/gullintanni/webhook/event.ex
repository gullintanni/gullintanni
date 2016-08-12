defmodule Gullintanni.Webhook.Event do
  @moduledoc """
  Provides functions related to extracting information from webhook events.
  """

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
  @spec get_payload(t) :: map
  def get_payload(%Plug.Conn{} = event), do: event.body_params
end
