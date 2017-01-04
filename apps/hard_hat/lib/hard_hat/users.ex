defmodule HardHat.Users do
  @moduledoc """
  A wrapper for the Users entity.

  <https://docs.travis-ci.com/api/#users>
  """

  import HardHat, except: [get: 2]
  alias HardHat.Client

  @doc """
  Show the authenticated user.

  ## Examples

      HardHat.Users.whoami(client)
  """
  @spec whoami(Client.t) :: HardHat.response
  def whoami(%Client{} = client) do
    HardHat.get(client, "users")
  end

  @doc """
  Gets the user identified by `id`.

  ## Examples

      HardHat.Users.get(client, 267)
      HardHat.Users.get(client, "267")
  """
  @spec get(Client.t, pos_integer | String.t) :: HardHat.response
  def get(%Client{} = client, id) when is_integer(id) and id > 0 do
    HardHat.get(client, "users/#{id}")
  end
  def get(%Client{} = client, id) when is_binary(id) do
    get(client, String.to_integer(id))
  end

  @doc """
  Trigger a new sync with GitHub.

  ## Examples

      HardHat.Users.sync(client)
  """
  @spec sync(Client.t) :: HardHat.response
  def sync(%Client{} = client) do
    post(client, "users/sync")
  end
end
