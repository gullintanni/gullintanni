defmodule Gullintanni.Repo do
  @moduledoc """
  A reference to a Git repository.
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

      iex> Gullintanni.Repo.new("elasticdog", "transcrypt")
      %Gullintanni.Repo{name: "transcrypt", owner: "elasticdog"}
  """
  @spec new(String.t, String.t) :: t
  def new(owner, name) do
    %Repo{
      owner: owner,
      name: name
    }
  end
end


defimpl String.Chars, for: Gullintanni.Repo do
  def to_string(repo) do
    "#{repo.owner}/#{repo.name}"
  end
end
