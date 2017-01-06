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
      HardHat.Jobs.get(client, "42")
  """
  @spec get(Client.t, pos_integer | String.t) :: HardHat.response
  def get(%Client{} = client, id) when is_integer(id) and id > 0 do
    HardHat.get(client, "jobs/#{id}")
  end
  def get(%Client{} = client, id) when is_binary(id) do
    get(client, String.to_integer(id))
  end

  @doc """
  Gets multiple jobs based on the given `params`.

  ## Examples

      HardHat.Jobs.get_all(client, [state: "passed"])
  """
  @spec get_all(Client.t, term) :: HardHat.response
  def get_all(%Client{} = client, params \\ []) do
    HardHat.get(client, "jobs/", params)
  end

  @doc """
  Cancels a job identified by `id`.

  ## Examples

      HardHat.Jobs.cancel(client, 42)
      HardHat.Jobs.cancel(client, "42")
  """
  @spec cancel(Client.t, pos_integer | String.t) :: HardHat.response
  def cancel(%Client{} = client, id) when is_integer(id) and id > 0 do
    post(client, "jobs/#{id}/cancel")
  end
  def cancel(%Client{} = client, id) when is_binary(id) do
    cancel(client, String.to_integer(id))
  end

  @doc """
  Restarts a job identified by `id`.

  ## Examples

      HardHat.Jobs.restart(client, 42)
      HardHat.Jobs.restart(client, "42")
  """
  @spec restart(Client.t, pos_integer | String.t) :: HardHat.response
  def restart(%Client{} = client, id) when is_integer(id) and id > 0 do
    post(client, "jobs/#{id}/restart")
  end
  def restart(%Client{} = client, id) when is_binary(id) do
    restart(client, String.to_integer(id))
  end
end
