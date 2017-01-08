defmodule HardHat.Repos do
  @moduledoc """
  A wrapper for the repository-related entities.

  * <https://docs.travis-ci.com/api/#repositories>
  * <https://docs.travis-ci.com/api/#repository-keys>
  """

  alias HardHat.Client
  alias HardHat.Repo
  alias HardHat.Response

  @doc """
  Gets the singular repository based on `path`.

  Returns `{:ok, repo}` if ...

  ## Examples

      HardHat.Repos.get("elasticdog/socket_address")
  """
  @spec get(Client.t, String.t) :: {:ok, Repo.t} | {:error, any}
  def get(%Client{} = client, path) do
    response = HardHat.get(client, "/repos/#{path}")
    format = %{"repo" => %Repo{}}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "repo")}
  end

  def search(%Client{} = client, path, params \\ []) do
    response = HardHat.get(client, "/repos/#{path}", params)
    format = %{"repos" => [%Repo{}]}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "repos")}
  end
end
