defmodule HardHat.Job do
  @moduledoc """
  Wraps the jobs API entity.

  <https://docs.travis-ci.com/api/#jobs>
  """

  import HardHat

  alias __MODULE__, as: Job
  alias HardHat.Client
  alias HardHat.Response

  @typedoc "The job type"
  @type t :: %__MODULE__{
    allow_failure: boolean,
    annotation_ids: [integer],
    build_id: integer,
    commit_id: integer,
    config: map,
    finished_at: String.t,
    id: integer,
    log_id: integer,
    number: String.t,
    queue: String.t,
    repository_id: integer,
    repository_slug: String.t,
    started_at: String.t,
    state: String.t,
    tags: String.t,
  }

  defstruct [
    :allow_failure,
    :annotation_ids,
    :build_id,
    :commit_id,
    :config,
    :finished_at,
    :id,
    :log_id,
    :number,
    :queue,
    :repository_id,
    :repository_slug,
    :started_at,
    :state,
    :tags,
  ]

  @doc """
  Fetches the job identified by `id`.

  ## Examples

      HardHat.Job.fetch(client, 42)
  """
  @spec fetch(Client.t, String.t) :: {:ok, Job.t} | {:error, any}
  def fetch(%Client{} = client, id) do
    response = get(client, "/jobs/#{id}")
    format = %{"job" => %Job{}}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "job")}
  end

  @doc """
  Fetches a list of jobs identified by `ids`.

  ## Examples

      HardHat.Job.fetch_ids(client, [8688, 11483077])
  """
  @spec fetch_ids(Client.t, [integer]) :: {:ok, [Job.t]} | {:error, any}
  def fetch_ids(%Client{} = client, ids) when is_list(ids) do
    params = Enum.map(ids, fn id -> {"ids[]", id} end)
    response = get(client, "/jobs", params)
    format = %{"jobs" => [%Job{}]}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "jobs")}
  end

  @doc """
  Cancels the job identified by `id`.

  ## Examples

      HardHat.Job.cancel(client, 42)
  """
  @spec cancel(Client.t, integer) :: HardHat.response
  def cancel(%Client{} = client, id) do
    post(client, "/jobs/#{id}/cancel")
    |> Response.parse
  end

  @doc """
  Restarts the job identified by `id`.

  ## Examples

      HardHat.Job.restart(client, 42)
  """
  @spec restart(Client.t, integer) :: HardHat.response
  def restart(%Client{} = client, id) do
    post(client, "/jobs/#{id}/restart")
    |> Response.parse
  end
end
