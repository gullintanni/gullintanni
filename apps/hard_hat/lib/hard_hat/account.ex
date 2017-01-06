defmodule HardHat.Account do
  @moduledoc """
  Defines a Travis CI account.

  <https://docs.travis-ci.com/api/#accounts>
  """

  @typedoc "The account type"
  @type t :: %__MODULE__{
    avatar_url: String.t,
    id: integer,
    login: String.t,
    name: String.t,
    repos_count: integer,
    type: String.t,
  }

  defstruct [
    :avatar_url,
    :id,
    :login,
    :name,
    :repos_count,
    :type,
  ]
end
