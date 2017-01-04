defmodule HardHat.Client do
  @moduledoc """
  Defines a client for connecting to the Travis CI API.

  A *client* is the combination of [authentication][] credentials and an
  [endpoint][] URL. Every call to the Travis CI API needs a client.

  [authentication]: https://docs.travis-ci.com/api/#authentication
  [endpoint]: https://docs.travis-ci.com/api/#overview
  """

  @typedoc "The API authentication credentials"
  @type auth :: %{access_token: String.t}

  @typedoc "The API endpoint URL"
  @type endpoint :: String.t

  @typedoc "The client type"
  @type t :: %__MODULE__{auth: auth, endpoint: endpoint}

  @enforce_keys [:auth, :endpoint]
  defstruct [:auth, :endpoint]

  @default_endpoint "https://api.travis-ci.org/"

  @doc """
  Creates a new client with the given `auth` and `endpoint`.

  Defaults to the _travis-ci.org_ endpoint for open source projects.
  """
  @spec new(auth, endpoint) :: t
  def new(auth, endpoint \\ @default_endpoint) do
    %__MODULE__{auth: auth, endpoint: HardHat.__normalize__(endpoint)}
  end
end
