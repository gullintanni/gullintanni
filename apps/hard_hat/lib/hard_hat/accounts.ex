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
  Lists the accounts the current user has access to.

  ## Examples

      HardHat.Accounts.list(client)
      HardHat.Accounts.list(client, [all: true])
  """
  @spec list(Client.t, term) :: HardHat.response
  def list(%Client{} = client, params \\ []) do
    get(client, "accounts/", params)
  end
end
