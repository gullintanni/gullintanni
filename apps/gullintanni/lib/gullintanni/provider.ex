defmodule Gullintanni.Provider do
  @moduledoc """
  Specifies the API that a provider module is required to implement.

  Providers are adapter modules that interface with a Git hosting service.
  """

  alias Gullintanni.Config
  alias Gullintanni.MergeRequest
  alias Gullintanni.Repo

  @typedoc "The provider type"
  @type t :: module

  @doc """
  Returns the domain name of the provider.
  """
  @callback domain() :: String.t

  @doc """
  Returns `true` if all required provider configuration values exist in
  `config`, otherwise `false`.
  """
  @callback valid_config?(Config.t) :: boolean

  @doc """
  Returns the provider account's effective user identity.
  """
  @callback whoami(Config.t) :: String.t

  @doc """
  Downloads a list of the repository's open merge requests.
  """
  @callback download_merge_requests(Repo.t, Config.t) :: [MergeRequest.t]

  @doc """
  Converts raw upstream data into a merge request.
  """
  @callback parse_merge_request(map) :: MergeRequest.t
end
