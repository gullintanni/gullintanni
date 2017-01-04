defmodule HardHat.Repos.Key do
  @moduledoc """
  A wrapper for the Repository Keys entities.

  This key can be used to encrypt (but not decrypt) secure env vars.

  <https://docs.travis-ci.com/api/#repository-keys>
  """

  import HardHat, except: [get: 2]
  alias HardHat.Client

  @doc """
  Gets the public key for the given `repo`.

  ## Examples

      HardHat.Repos.Key.get(client, "elasticdog/socket_address")
  """
  @spec get(Client.t, String.t) :: String.t | HardHat.Response.t
  def get(%Client{} = client, repo) when is_binary(repo) do
    case _get(client, repo) do
      %{"key" => key} -> key
      error -> error
    end
  end

  @doc """
  Gets the public key fingerprint for the given `repo`.

  ## Examples

      HardHat.Repos.Key.get_fingerprint(client, "elasticdog/socket_address")
  """
  @spec get_fingerprint(Client.t, String.t) :: String.t | HardHat.Response.t
  def get_fingerprint(client, repo) when is_binary(repo) do
    case _get(client, repo) do
      %{"fingerprint" => fingerprint} -> fingerprint
      error -> error
    end
  end

  @spec _get(Client.t, String.t) :: HardHat.Response.t
  defp _get(client, repo) do
    HardHat.get(client, "repos/" <> HardHat.__normalize__(repo) <> "key")
  end

  @doc """
  Generates a new repository keypair.

  This will invalidate the current key, thus also rendering all encrypted
  variables invalid.
  """
  @spec generate(Client.t, String.t) :: HardHat.Response.t
  def generate(%Client{} = client, repo) when is_binary(repo) do
    post(client, "repos/" <> HardHat.__normalize__(repo) <> "key")
  end
end