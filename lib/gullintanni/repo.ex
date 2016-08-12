defmodule Gullintanni.Repo do
  @moduledoc """
  Defines a Git repository.
  """

  alias __MODULE__, as: Repo

  @typedoc "The repository type"
  @type t ::
    %Repo{
      owner: String.t,
      name: String.t
    }

  @enforce_keys [:owner, :name]
  defstruct [:owner, :name]

  @doc """
  Creates a new repository with the given metadata.

  ## Examples

      iex> Gullintanni.Repo.new("elixir-lang", "elixir")
      #Repo<owner: "elixir-lang", name: "elixir">
  """
  @spec new(String.t, String.t) :: t
  def new(owner, name) do
    %Repo{
      owner: owner,
      name: name
    }
  end
end


defimpl Inspect, for: Gullintanni.Repo do
  import Inspect.Algebra

  def inspect(repo, opts) do
    owner = "owner: #{inspect repo.owner}"
    name = "name: #{inspect repo.name}"

    surround_many("#Repo<", [owner, name], ">",
      opts, fn(i, _opts) -> i end)
  end
end


defimpl String.Chars, for: Gullintanni.Repo do
  def to_string(repo) do
    "#{repo.owner}/#{repo.name}"
  end
end
