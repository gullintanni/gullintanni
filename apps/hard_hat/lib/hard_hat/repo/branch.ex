defmodule HardHat.Repo.Branch do
  @moduledoc """
  Defines a repository branch.
  """

  @typedoc "The branch type"
  @type t :: %__MODULE__{
    commit_id: integer,
    config: map,
    duration: integer,
    finished_at: String.t,
    id: integer,
    job_ids: [integer],
    number: String.t,
    pull_request: boolean,
    repository_id: integer,
    started_at: String.t,
    state: String.t,
  }

  defstruct [
    :commit_id,
    :config,
    :duration,
    :finished_at,
    :id,
    :job_ids,
    :number,
    :pull_request,
    :repository_id,
    :started_at,
    :state,
  ]
end
