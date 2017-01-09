defmodule HardHat.User do
  @moduledoc """
  Wraps the users API entity.

  <https://docs.travis-ci.com/api/#users>
  """

  import HardHat

  alias __MODULE__, as: User
  alias HardHat.Client
  alias HardHat.Response

  @typedoc "The user type"
  @type t :: %__MODULE__{
    channels: [String.t],
    correct_scopes: boolean,
    created_at: String.t,
    email: String.t,
    gravatar_id: String.t,
    id: integer,
    is_syncing: boolean,
    locale: String.t,
    login: String.t,
    name: String.t,
    synced_at: String.t,
  }

  defstruct [
    :channels,
    :correct_scopes,
    :created_at,
    :email,
    :gravatar_id,
    :id,
    :is_syncing,
    :locale,
    :login,
    :name,
    :synced_at,
  ]

  @doc """
  Gets the currently authenticated user.

  ## Examples

      HardHat.User.whoami(client)
  """
  @spec whoami(Client.t) :: t | {:error, any}
  def whoami(%Client{} = client) do
    response = get(client, "/users")
    format = %{"user" => %User{}}

    with {:ok, data} <- Response.parse(response, format),
         do: Map.get(data, "user")
  end

  @doc """
  Gets the user identified by `id`.

  ## Examples

      HardHat.User.fetch(client, 267)
  """
  @spec fetch(Client.t, integer) :: {:ok, t} | {:error, any}
  def fetch(%Client{} = client, id) do
    response = get(client, "/users/#{id}")
    format = %{"user" => %User{}}

    with {:ok, data} <- Response.parse(response, format),
         do: {:ok, Map.get(data, "user")}
  end

  @doc """
  Triggers a synchronization with GitHub.

  ## Examples

      HardHat.User.sync(client)
  """
  @spec sync(Client.t) :: :ok | {:error, any}
  def sync(%Client{} = client) do
    response = post(client, "/users/sync")

    case Response.parse(response) do
      {:ok, _} -> :ok
      error -> error
    end
  end
end
