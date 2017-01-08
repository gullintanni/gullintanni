defmodule HardHat.Repo do
  @moduledoc """
  Defines a repo.

  <https://docs.travis-ci.com/api/#repos>
  """

  @typedoc "The repo type"
  @type t :: %__MODULE__{
    active: boolean,
    description: String.t,
    github_language: String.t,
    id: integer,
    last_build_duration: integer,
    last_build_finished_at: String.t,
    last_build_id: integer,
    last_build_language: String.t,
    last_build_number: String.t,
    last_build_started_at: String.t,
    last_build_state: String.t,
    slug: String.t,
  }

  defstruct [
    :active,
    :description,
    :github_language,
    :id,
    :last_build_duration,
    :last_build_finished_at,
    :last_build_id,
    :last_build_language,
    :last_build_number,
    :last_build_started_at,
    :last_build_state,
    :slug,
  ]
end
