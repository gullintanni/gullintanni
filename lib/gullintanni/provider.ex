defmodule Gullintanni.Provider do
  @moduledoc """
  This module specifies the API that a provider is required to implement.

  Providers are adapter modules that interface with a Git hosting service.
  """

  @type config :: Keyword.t
  @type t :: module

  @doc """
  Returns `:ok` if all required configuration values exist in `config`,
  otherwise raises an `ArgumentError`.
  """
  @callback validate_config(config) :: :ok | no_return

  @doc """
  Returns the account's effective user identity.
  """
  @callback whoami(config) :: String.t
end
