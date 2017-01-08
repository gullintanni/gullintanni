defmodule HardHat.Repo do
  @moduledoc """
  Handles the repository-related API entities.

  * <https://docs.travis-ci.com/api/#repositories>
  * <https://docs.travis-ci.com/api/#repository-keys>
  """

  import HardHat

  alias __MODULE__, as: Repo
  alias HardHat.Client
  alias HardHat.Response

  @typedoc "The repo type"
  @type t :: %__MODULE__{
    active: boolean,
    description: String.t,
    github_language: String.t,
    id: integer,
    last_build_duration: integer,
    last_build_finished_at: String.t,
    last_build_id: integer,
    last_build_language: String.t,
    last_build_number: String.t,
    last_build_started_at: String.t,
    last_build_state: String.t,
    slug: String.t,
  }

  defstruct [
    :active,
    :description,
    :github_language,
    :id,
    :last_build_duration,
    :last_build_finished_at,
    :last_build_id,
    :last_build_language,
    :last_build_number,
    :last_build_started_at,
    :last_build_state,
    :slug,
  ]

  @doc """
  Fetches a repository identified by `repo`.

  The `repo` must be a slug or id number that identifies a single repository.

  ## Examples

      HardHat.Repo.fetch(client, "elasticdog/socket_address")
      HardHat.Repo.fetch(client, 11483077)
  """
  @spec fetch(Client.t, String.t) :: {:ok, Repo.t} | {:error, any}
  def fetch(%Client{} = client, repo) do
    response = get(client, "/repos/#{repo}")
    format = %{"repo" => %Repo{}}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "repo")}
  end

  @doc """
  Fetches a list of repositories identified by `ids`.

  ## Examples

      HardHat.Repo.fetch_ids(client, [8688, 11483077])
  """
  @spec fetch_ids(Client.t, [integer]) :: {:ok, [Repo.t]} | {:error, any}
  def fetch_ids(%Client{} = client, ids) do
    params = Enum.map(ids, fn id -> {"ids[]", id} end)
    response = get(client, "/repos", params)
    format = %{"repos" => [%Repo{}]}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "repos")}
  end

  @doc """
  Returns a list of repositories based on the search `params`.

  ## Options

  The accepted options are:

    * `:member` - filter by user that has access to it (GitHub login)
    * `:owner_name` - filter by owner name (first segment of slug)
    * `:slug` - filter by slug
    * `:search` - filter by search term
    * `:active` - if `true`, will only return repositories that are enabled;
      defaults to `false`.

  ## Examples

      HardHat.Repo.search(client, [owner_name: "elasticdog"])
  """
  def search(%Client{} = client, params \\ []) do
    response = HardHat.get(client, "/repos", params)
    format = %{"repos" => [%Repo{}]}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "repos")}
  end
end
