defmodule Gullintanni.Worker do
  @moduledoc """
  Specifies the API that a worker module is required to implement.

  Workers are adapter modules that interface with a CI service.
  """

  alias Gullintanni.Config

  @typedoc "The worker type"
  @type t :: module

  @doc """
  Returns `true` if all required worker configuration values exist in `config`,
  otherwise `false`.
  """
  @callback valid_config?(Config.t) :: boolean

  @doc """
  Returns the worker account's effective user identity.
  """
  @callback whoami(Config.t) :: String.t
end
