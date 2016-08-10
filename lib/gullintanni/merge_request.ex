defmodule Gullintanni.MergeRequest do
  @moduledoc """
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
    * `:state` - the state of the merge request; valid states are defined by `t:state/0`
  """
  @spec new(id, Keyword.t) :: t
  def new(id, opts \\ []) do
    Enum.reduce(opts, %MergeRequest{id: id}, fn({key, value}, req) ->
      %{req | key => value}
    end)
  end

  # A basic Finite State Machine

  def approve(%MergeRequest{state: :under_review} = req),
    do: %{req | state: :approved}

  def unapprove(%MergeRequest{} = req),
    do: %{req | state: :under_review}

  def merge_passed(%MergeRequest{state: :approved} = req),
    do: %{req | state: :build_pending}

  def merge_failed(%MergeRequest{state: :approved} = req),
    do: %{req | state: :error}

  def build_passed(%MergeRequest{state: :build_pending} = req),
    do: %{req | state: :build_passed}

  def build_failed(%MergeRequest{state: :build_pending} = req),
    do: %{req | state: :build_failed}

  def build_error(%MergeRequest{state: :build_pending} = req),
    do: %{req | state: :error}

  def ffwd_failed(%MergeRequest{state: :build_passed} = req),
    do: %{req | state: :error}
end


defimpl Inspect, for: Gullintanni.MergeRequest do
  import Inspect.Algebra

  def inspect(req, opts) do
    keys = [:id, :state, :title, :url]
    attributes =
      keys
      |> Enum.reduce([], fn(key, attributes) ->
           value = Map.get(req, key)
           case value do
             nil -> attributes
             _ -> ["#{key}: #{inspect value}"|attributes]
           end
         end)
      |> Enum.reverse

    surround_many("#MergeRequest<", attributes, ">",
      opts, fn(i, _opts) -> i end)
  end
end
