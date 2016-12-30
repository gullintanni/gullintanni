defmodule HardHat.Users do
  @moduledoc """
  A wrapper for the Users entity.

  <https://docs.travis-ci.com/api/#users>
  """

  import HardHat
  alias HardHat.Client

  @doc """
  Show the authenticated user.

  ## Examples

      HardHat.Users.whoami(client)
  """
  @spec whoami(Client.t) :: HardHat.response
  def whoami(client) do
    get(client, "users")
  end

  @doc """
  Show the user identified by `id`.

  ## Examples

      HardHat.Users.show(client, 267)
  """
  @spec show(Client.t, pos_integer) :: HardHat.response
  def show(client, id) do
    get(client, "users/#{id}")
  end

  @doc """
  Trigger a new sync with GitHub.

  ## Examples

      HardHat.Users.sync(client)
  """
  @spec sync(Client.t) :: HardHat.response
  def sync(client) do
    post(client, "users/sync")
  end
end
