defmodule HardHat.Account do
  @moduledoc """
  Wraps the accounts API entity.

  A user might have access to multiple accounts. This is usually the account
  corresponding to the user directly and one account per GitHub organization.

  <https://docs.travis-ci.com/api/#accounts>
  """

  import HardHat

  alias __MODULE__, as: Account
  alias HardHat.Client
  alias HardHat.Response

  @typedoc "The account type"
  @type t :: %__MODULE__{
    avatar_url: String.t,
    id: integer,
    login: String.t,
    name: String.t,
    repos_count: integer,
    type: String.t,
  }

  defstruct [
    :avatar_url,
    :id,
    :login,
    :name,
    :repos_count,
    :type,
  ]

  @doc """
  Lists the accounts the current user has admin access to.

  ## Examples

      HardHat.Accounts.list(client)
  """
  @spec list(Client.t) :: {:ok, [Account.t]} | {:error, any}
  def list(%Client{} = client) do
    response = get(client, "/accounts")
    format = %{"accounts" => [%Account{}]}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "accounts")}
  end

  @doc """
  Lists the accounts the current user has access to, including accounts without
  admin access.

  ## Examples

      HardHat.Accounts.list_all(client)
  """
  @spec list_all(Client.t) ::  {:ok, [Account.t]} | {:error, any}
  def list_all(%Client{} = client) do
    response = get(client, "/accounts", [all: true])
    format = %{"accounts" => [%Account{}]}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "accounts")}
  end
end
