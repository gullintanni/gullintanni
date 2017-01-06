defmodule HardHat.Jobs do
  @moduledoc """
  A wrapper for the Jobs entity.

  <https://docs.travis-ci.com/api/#jobs>
  """

  import HardHat, except: [get: 2]
  alias HardHat.Client

  @doc """
  Gets the job identified by `id`.

  ## Examples

      HardHat.Jobs.get(client, 42)
  """
  @spec get(Client.t, pos_integer) :: HardHat.response
  def get(%Client{} = client, id) do
    HardHat.get(client, "/jobs/#{id}")
  end

  @doc """
  Gets all jobs, filtered by the `params`.

  ## Examples

      HardHat.Jobs.get_all(client, [state: "passed"])
  """
  @spec get_all(Client.t, term) :: HardHat.response
  def get_all(%Client{} = client, params \\ []) do
    HardHat.get(client, "/jobs", params)
  end

  @doc """
  Cancels the job identified by `id`.

  ## Examples

      HardHat.Jobs.cancel(client, 42)
  """
  @spec cancel(Client.t, pos_integer) :: HardHat.response
  def cancel(%Client{} = client, id) do
    post(client, "/jobs/#{id}/cancel")
  end

  @doc """
  Restarts the job identified by `id`.

  ## Examples

      HardHat.Jobs.restart(client, 42)
  """
  @spec restart(Client.t, pos_integer) :: HardHat.response
  def restart(%Client{} = client, id) do
    post(client, "/jobs/#{id}/restart")
  end
end
