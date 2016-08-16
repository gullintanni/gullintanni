defmodule Gullintanni.Providers.GitHub do
  @moduledoc """
  Provider adapter module for GitHub -- https://github.com/.
  """

  alias Gullintanni.Config
  alias Gullintanni.MergeRequest
  alias Gullintanni.Repo

  @behaviour Gullintanni.Provider

  @domain "github.com"
  @default_endpoint "https://api.github.com/"
  @required_config_settings [:provider_auth_token]

  def __domain__, do: @domain

  def valid_config?(config) do
    Config.settings_present?(@required_config_settings, config)
  end

  def whoami(config) do
    Tentacat.Users.me(client(config))["login"]
  end

  def download_merge_requests(%Repo{} = repo, config) do
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

  @spec client(Config.t) :: Tentacat.Client.t
  defp client(config) do
    endpoint = config[:provider_endpoint] || @default_endpoint
    Tentacat.Client.new(%{access_token: config[:provider_auth_token]}, endpoint)
  end
end
