defmodule HardHat.Users do
  @moduledoc """
  A wrapper for the Users entity.

  <https://docs.travis-ci.com/api/#users>
  """

  import HardHat, except: [get: 2]
  alias HardHat.Client

  @doc """
  Gets the currently authenticated user.

  ## Examples

      HardHat.Users.whoami(client)
  """
  @spec whoami(Client.t) :: HardHat.response
  def whoami(%Client{} = client) do
    HardHat.get(client, "/users")
  end

  @doc """
  Gets the user identified by `id`.

  ## Examples

      HardHat.Users.get(client, 267)
  """
  @spec get(Client.t, pos_integer) :: HardHat.response
  def get(%Client{} = client, id) do
    HardHat.get(client, "/users/#{id}")
  end

  @doc """
  Triggers a synchronization with GitHub.

  ## Examples

      HardHat.Users.sync(client)
  """
  @spec sync(Client.t) :: HardHat.response
  def sync(%Client{} = client) do
    post(client, "/users/sync")
  end
end
