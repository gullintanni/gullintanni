defmodule Gullintanni.Repo do
  @moduledoc """
  Defines a Git repository.
  """

  alias __MODULE__, as: Repo
  alias Gullintanni.Provider

  @typedoc "The repository type"
  @type t ::
    %Repo{
      provider: Provider.t,
      owner: String.t,
      name: String.t
    }

  @enforce_keys [:provider, :owner, :name]
  defstruct [:provider, :owner, :name]

  @doc """
  Creates a new repository with the given metadata.

  ## Examples

      iex> Gullintanni.Repo.new(Gullintanni.Providers.GitHub, "elixir-lang", "elixir")
      #Repo<github.com/elixir-lang/elixir>
  """
  @spec new(Provider.t, String.t, String.t) :: t
  def new(provider, owner, name) do
    %Repo{
      provider: provider,
      owner: owner,
      name: name
    }
  end
end


defimpl Inspect, for: Gullintanni.Repo do
  import Inspect.Algebra

  def inspect(repo, _opts) do
    surround("#Repo<", "#{repo}", ">")
  end
end


defimpl String.Chars, for: Gullintanni.Repo do
  def to_string(repo) do
    provider = repo.provider.__domain__
    "#{provider}/#{repo.owner}/#{repo.name}"
  end
end
