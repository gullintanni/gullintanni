defmodule HardHat.Repos.Branches do
  @moduledoc """
  A wrapper for the Branches entities.

  <https://docs.travis-ci.com/api/#branches>
  """

  alias HardHat.Client

  @doc """
  Lists all the branches for a `repo`.

  ## Examples

      HardHat.Repos.Branches.list(client, "elasticdog/socket_address")
  """
  @spec list(Client.t, String.t) :: HardHat.Response.t
  def list(%Client{} = client, repo) do
    HardHat.get(client, "/repos/#{repo}/branches")
  end

  @doc """
  Gets a specific `branch` for a `repo`.

  ## Examples

      HardHat.Repos.Branches.get(client, "elasticdog/socket_address", "v0.2.0")
  """
  @spec get(Client.t, String.t, String.t) :: HardHat.Response.t
  def get(%Client{} = client, repo, branch) do
    HardHat.get(client, "/repos/#{repo}/branches/#{branch}")
  end
end
