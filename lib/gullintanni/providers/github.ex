defmodule Gullintanni.Providers.GitHub do
  @behaviour Gullintanni.Provider

  def whoami do
    Tentacat.Users.me(client())["login"]
  end

  defp client do
    config = Application.get_env(:gullintanni, :pipeline, [])
    token = config[:auth_token]
    Tentacat.Client.new(%{access_token: token})
  end
end
