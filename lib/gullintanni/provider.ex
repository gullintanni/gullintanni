defmodule Gullintanni.Provider do
  @moduledoc """
  This module specifies the API that a provider is required to implement.

  Providers implement the functionality for interacting with an external Git
  hosting service.
  """

  @doc """
  Returns the account's effective user identity.
  """
  @callback whoami() :: String.t
end
