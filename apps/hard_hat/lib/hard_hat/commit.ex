defmodule HardHat.Commit do
  @moduledoc """
  Defines a commit.
  """

  @typedoc "The account type"
  @type t :: %__MODULE__{
    author_email: String.t,
    author_name: String.t,
    branch: String.t,
    branch_is_default: boolean,
    committed_at: String.t,
    committer_email: String.t,
    committer_name: String.t,
    compare_url: String.t,
    id: integer,
    message: String.t,
    sha: String.t,
  }

  defstruct [
    :author_email,
    :author_name,
    :branch,
    :branch_is_default,
    :committed_at,
    :committer_email,
    :committer_name,
    :compare_url,
    :id,
    :message,
    :sha,
  ]
end
