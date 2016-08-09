defmodule Gullintanni.Providers.GitHub do
  alias Gullintanni.MergeRequest
  alias Gullintanni.Provider

  @behaviour Gullintanni.Provider

  @default_endpoint "https://api.github.com/"

  def validate_config(config) do
    required_keys = [:provider_auth_token]

    Enum.each(required_keys, fn(key) ->
      unless Keyword.has_key?(config, key),
        do: raise ArgumentError, "missing #{inspect key} configuration setting"
    end)

    :ok
  end

  def whoami(config) do
    Tentacat.Users.me(client(config))["login"]
  end

  def get_merge_requests(repo, config) do
    Tentacat.Pulls.list(repo.owner, repo.name, client(config))
    |> Enum.map(&parse_merge_request/1)
  end

  def parse_merge_request(data) do
    MergeRequest.new(
      data["number"],
      [
        title: data["title"],
        clone_url: data["head"]["repo"]["clone_url"],
        branch_name: data["head"]["ref"],
        target_branch: data["base"]["ref"],
        latest_commit: data["head"]["sha"]
      ]
    )
  end

  @spec client(Provider.config) :: Tentacat.Client.t
  defp client(config) do
    endpoint = config[:provider_endpoint] || @default_endpoint
    Tentacat.Client.new(%{access_token: config[:provider_auth_token]}, endpoint)
  end
end
