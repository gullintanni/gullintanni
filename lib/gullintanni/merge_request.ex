defmodule Gullintanni.MergeRequest do
  @moduledoc """
  Defines a merge request.
  """

  alias __MODULE__, as: MergeRequest

  @typedoc "A merge request identifier"
  @type id :: pos_integer

  @typedoc "A 40 character SHA-1 hash"
  @type sha :: String.t

  @typedoc "Supported merge request states"
  @type state :: :under_review | :approved | :build_pending | :build_passed
               | :build_failed | :error

  @type t ::
    %MergeRequest{
      id: id,
      title: String.t,
      url: String.t,
      clone_url: String.t,
      branch_name: String.t,
      target_branch: String.t,
      latest_commit: sha,
      approved_by: %{optional(String.t) => NaiveDateTime.t},
      state: state
    }

  @enforce_keys [:id]
  defstruct [
    :id,
    :title,
    :url,
    :clone_url,
    :branch_name,
    :target_branch,
    :latest_commit,
    approved_by: %{},
    state: :under_review
  ]

  @doc """
  Creates a new merge request with the given `id`.

  ## Options

  The accepted options are:

    * `:title` - the title of the merge request
    * `:url` - the URL for viewing the merge request discussion
    * `:clone_url` - the URL for Git to use when cloning the merge request
    * `:branch_name` - the Git branch name of the merge request
    * `:target_branch` - the name of the Git branch that the merge request is targeting
    * `:latest_commit` - the SHA-1 hash of the latest commit on the merge request
    * `:approved_by` - the users that have approved the merge request
    * `:state` - the state of the merge request; valid states are defined by `t:state/0`
  """
  @spec new(id, Keyword.t) :: t
  def new(id, opts \\ []) do
    Enum.reduce(opts, %MergeRequest{id: id}, fn({key, value}, mreq) ->
      %{mreq | key => value}
    end)
  end

  @doc """
  Replaces the latest commit on the merge request with `sha`.

  This will reset the state back to "under review" as well, canceling any
  existing approvals.
  """
  @spec update_sha(t, sha) :: t
  def update_sha(%MergeRequest{} = mreq, sha) do
    %{mreq | latest_commit: sha} |> reset
  end

  @spec approved_at(t) :: NaiveDateTime.t
  def approved_at(%MergeRequest{} = mreq) do
    mreq.approved_by
    |> Map.values
    |> Enum.sort
    |> List.first
  end

  # A basic Finite State Machine

  def reset(%MergeRequest{} = mreq) do
    %{mreq | state: :under_review, approved_by: %{}}
  end

  @spec approve(t, String.t, NaiveDateTime.t) :: t
  def approve(%MergeRequest{state: :under_review} = mreq, username, timestamp) do
    %{mreq | state: :approved,
             approved_by: Map.put_new(mreq.approved_by, username, timestamp)}
  end
  def approve(%MergeRequest{} = mreq, _username, _timestamp) do
    mreq
  end

  def unapprove(%MergeRequest{} = mreq, _username) do
    reset(mreq)
  end

  def merge_passed(%MergeRequest{state: :approved} = mreq),
    do: %{mreq | state: :build_pending}

  def merge_failed(%MergeRequest{state: :approved} = mreq),
    do: %{mreq | state: :error}

  def build_passed(%MergeRequest{state: :build_pending} = mreq),
    do: %{mreq | state: :build_passed}

  def build_failed(%MergeRequest{state: :build_pending} = mreq),
    do: %{mreq | state: :build_failed}

  def build_error(%MergeRequest{state: :build_pending} = mreq),
    do: %{mreq | state: :error}

  def ffwd_failed(%MergeRequest{state: :build_passed} = mreq),
    do: %{mreq | state: :error}
end


defimpl Inspect, for: Gullintanni.MergeRequest do
  import Inspect.Algebra

  def inspect(mreq, opts) do
    keys = [:id, :state, :title, :url]
    attributes =
      keys
      |> Enum.reduce([], fn(key, attributes) ->
           value = Map.get(mreq, key)
           case value do
             nil -> attributes
             _ -> ["#{key}: #{inspect value}" | attributes]
           end
         end)
      |> Enum.reverse

    surround_many("#MergeRequest<", attributes, ">",
      opts, fn(i, _opts) -> i end)
  end
end
