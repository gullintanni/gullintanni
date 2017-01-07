defmodule HardHat.Accounts do
  @moduledoc """
  A wrapper for the Accounts entity.

  A user might have access to multiple accounts. This is usually the account
  corresponding to the user directly and one account per GitHub organization.

  <https://docs.travis-ci.com/api/#accounts>
  """

  import HardHat
  alias HardHat.Account
  alias HardHat.Client
  alias HardHat.Response

  @doc """
  Lists the accounts the current user has admin access to.

  ## Examples

      HardHat.Accounts.list(client)
  """
  @spec list(Client.t) :: {:ok, [Account.t]} | Response.error
  def list(%Client{} = client) do
    client
    |> get("/accounts")
    |> Response.parse({"accounts", %Account{}})
  end

  @doc """
  Lists the accounts the current user has access to, including accounts without
  admin access.

  ## Examples

      HardHat.Accounts.list_all(client)
  """
  @spec list_all(Client.t) :: HardHat.Response.t
  def list_all(%Client{} = client) do
    client
    |> get("/accounts", [all: true])
    |> Response.parse({"accounts", %Account{}})
  end
end
