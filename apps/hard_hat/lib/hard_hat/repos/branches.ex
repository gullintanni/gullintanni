defmodule HardHat.Repos.Branches do
  @moduledoc """
  A wrapper for the Branches entities.

  <https://docs.travis-ci.com/api/#branches>
  """

  alias HardHat.Client

  @doc """
  Lists the branches for the given `repo`.

  ## Examples

      HardHat.Repos.Branches.list(client, "elasticdog/socket_address")
  """
  @spec list(Client.t, String.t) :: HardHat.Response.t
  def list(%Client{} = client, repo) when is_binary(repo) do
    HardHat.get(client, "repos/" <> HardHat.__normalize__(repo) <> "branches/")
  end

  @doc """
  Gets the info for a specific repository `branch`.

  ## Examples

      HardHat.Repos.Branches.get(client, "elasticdog/socket_address", "v0.2.0")
  """
  @spec get(Client.t, String.t, String.t) :: HardHat.Response.t
  def get(%Client{} = client, repo, branch)
      when is_binary(repo) and is_binary(branch) do
    HardHat.get(client,
                "repos/" <>
                HardHat.__normalize__(repo) <>
                "branches/#{branch}")
  end
end
