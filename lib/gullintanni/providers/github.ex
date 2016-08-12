defmodule Gullintanni.Providers.GitHub do
  alias Gullintanni.MergeRequest
  alias Gullintanni.Provider
  require Logger

  @behaviour Gullintanni.Provider

  @default_endpoint "https://api.github.com/"

  def valid_config?(config) do
    required_keys = [:provider_auth_token]

    Enum.reduce(required_keys, true, fn(key, answer) ->
      case Keyword.has_key?(config, key) do
        true -> answer
        false ->
          _ = Logger.error "missing #{inspect key} configuration setting"
          false
      end
    end)
  end

  def whoami(config) do
    Tentacat.Users.me(client(config))["login"]
  end

  def download_merge_requests(repo, config) do
    Tentacat.Pulls.list(repo.owner, repo.name, client(config))
    |> Enum.map(&parse_merge_request/1)
  end

  def parse_merge_request(data) do
    MergeRequest.new(
      data["number"],
      [
        title: data["title"],
        url: data["html_url"],
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
