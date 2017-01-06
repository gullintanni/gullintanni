defmodule HardHat.Repos do
  @moduledoc """
  A wrapper for the Repositories entities.

  <https://docs.travis-ci.com/api/#repositories>
  """

  alias HardHat.Client

  @doc """
  Gets the repositories based on `path` and `params`.

  ## Examples

      HardHat.Repos.get("elasticdog/socket_address")
      HardHat.Repos.get("elasticdog", [search: "elixir"])
  """
  @spec get(Client.t, String.t, term) :: HardHat.response
  def get(%Client{} = client, path, params \\ []) do
    HardHat.get(client, "repos/" <> path, params)
  end
end
