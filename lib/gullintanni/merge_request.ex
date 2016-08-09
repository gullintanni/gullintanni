defmodule Gullintanni.MergeRequest do
  @moduledoc """
  """

  alias __MODULE__, as: MergeRequest

  @typedoc "A merge request identifier"
  @type id :: pos_integer

  @typedoc "A 40 character SHA-1 hash"
  @type sha :: String.t

  @typedoc "Supported merge request states"
  @type state :: :discussing | :approved | :pending | :passed | :failed | :error

  @type t ::
    %MergeRequest{
      id: id,
      title: String.t,
      clone_url: String.t,
      branch_name: String.t,
      target_branch: String.t,
      latest_commit: sha,
      state: state
    }

  @enforce_keys [:id]
  defstruct [
    :id,
    :title,
    :clone_url,
    :branch_name,
    :target_branch,
    :latest_commit,
    state: :discussing
  ]

  @doc """
  Creates a new merge request with the given `id`.

  ## Options

  The accepted options are:

    * `:title` - the title of the merge request
    * `:clone_url` - the URL for Git to use when cloning the merge request
    * `:branch_name` - the Git branch name of the merge request
    * `:target_branch` - the name of the Git branch that the merge request is targeting
    * `:latest_commit` - the SHA-1 hash of the latest commit on the merge request
    * `:state` - the state of the merge request; valid states are defined by `t:state/0`
  """
  @spec new(id, Keyword.t) :: t
  def new(id, opts \\ []) do
    Enum.reduce(opts, %MergeRequest{id: id}, fn({key, value}, req) ->
      %{req | key => value}
    end)
  end

  # A basic Finite State Machine

  def approve(%MergeRequest{state: :discussing} = req),
    do: %{req | state: :approved}

  def unapprove(%MergeRequest{} = req),
    do: %{req | state: :discussing}

  def merge_pass(%MergeRequest{state: :approved} = req),
    do: %{req | state: :pending}

  def merge_fail(%MergeRequest{state: :approved} = req),
    do: %{req | state: :error}

  def build_pass(%MergeRequest{state: :pending} = req),
    do: %{req | state: :passed}

  def build_fail(%MergeRequest{state: :pending} = req),
    do: %{req | state: :failed}

  def build_error(%MergeRequest{state: :pending} = req),
    do: %{req | state: :error}

  def ffwd_fail(%MergeRequest{state: :passed} = req),
    do: %{req | state: :error}
end
