defmodule Gullintanni.Provider do
  @moduledoc """
  This module specifies the API that a provider is required to implement.

  Providers are adapter modules that interface with a Git hosting service.
  """

  alias Gullintanni.MergeRequest
  alias Gullintanni.Repo

  @type config :: Keyword.t
  @type t :: module

  @doc """
  Returns `:ok` if all required provider configuration values exist in
  `config`, otherwise raises an `ArgumentError` exception.
  """
  @callback validate_config(config) :: :ok | no_return

  @doc """
  Returns the provider account's effective user identity.
  """
  @callback whoami(config) :: String.t

  @doc """
  Downloads a list of the repository's open merge requests.
  """
  @callback download_merge_requests(Repo.t, config) :: [MergeRequest.t]

  @doc """
  Converts raw upstream data into a merge request.
  """
  @callback parse_merge_request(map) :: MergeRequest.t
end
