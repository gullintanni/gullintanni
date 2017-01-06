defmodule HardHat.Accounts do
  @moduledoc """
  A wrapper for the Accounts entity.

  A user might have access to multiple accounts. This is usually the account
  corresponding to the user directly and one account per GitHub organization.

  <https://docs.travis-ci.com/api/#accounts>
  """

  import HardHat
  alias HardHat.Client

  @doc """
  Lists the accounts the current user has admin access to.

  ## Examples

      HardHat.Accounts.list(client)
  """
  @spec list(Client.t) :: HardHat.response
  def list(%Client{} = client) do
    get(client, "/accounts")
  end

  @doc """
  Lists the accounts the current user has access to, including accounts without
  admin access.

  ## Examples

      HardHat.Accounts.list_all(client)
  """
  @spec list_all(Client.t) :: HardHat.response
  def list_all(%Client{} = client) do
    get(client, "/accounts", [all: true])
  end
end
