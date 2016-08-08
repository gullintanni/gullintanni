defmodule Gullintanni.Providers.GitHub do
  @behaviour Gullintanni.Provider

  def validate_config(config) do
    unless config[:provider_auth_token] do
      raise ArgumentError, "missing :provider_auth_token configuration"
    end

    :ok
  end

  def whoami(config) do
    Tentacat.Users.me(client(config))["login"]
  end

  defp client(config) do
    Tentacat.Client.new(%{access_token: config[:provider_auth_token]})
  end
end
