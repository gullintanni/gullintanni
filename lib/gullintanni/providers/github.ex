defmodule Gullintanni.Providers.GitHub do
  @behaviour Gullintanni.Provider

  @default_endpoint "https://api.github.com/"

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
    endpoint = config[:provider_endpoint] || @default_endpoint
    Tentacat.Client.new(%{access_token: config[:provider_auth_token]}, endpoint)
  end
end
