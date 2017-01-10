defmodule Gullintanni.Providers.GitHub do
  @moduledoc """
  Provider adapter module for GitHub -- https://github.com/
  """

  alias Gullintanni.Comment
  alias Gullintanni.Config
  alias Gullintanni.MergeRequest
  alias Gullintanni.Repo

  @behaviour Gullintanni.Provider

  @default_endpoint "https://api.github.com/"
  @display_name "GitHub"
  @domain "github.com"
  @required_config_settings [:provider_auth_token]

  def display_name(), do: @display_name

  def domain(), do: @domain

  def valid_config?(config) do
    Config.settings_present?(@required_config_settings, config)
  end

  @spec client(Config.t) :: Tentacat.Client.t
  defp client(config) do
    endpoint = config[:provider_endpoint] || @default_endpoint
    Tentacat.Client.new(%{access_token: config[:provider_auth_token]}, endpoint)
  end

  def whoami(config) do
    Tentacat.Users.me(client(config))["login"]
  end

  def download_merge_requests(%Repo{} = repo, config) do
    Tentacat.Pulls.list(repo.owner, repo.name, client(config))
    |> Enum.map(&parse_merge_request/1)
  end

  @doc """
  Publishes a comment in response to the given `message`.
  """
  @spec post_comment(Repo.t, MergeRequest.id, String.t, Config.t) :: :ok | :error
  def post_comment(%Repo{} = repo, thread, comment, config) do
    response =
      Tentacat.Issues.Comments.create(
        repo.owner,
        repo.name,
        thread,
        %{body: comment},
        client(config)
      )

    case response do
      {201, _} -> :ok
      _ -> :error
    end
  end

  ## Parsing API data

  @spec parse_repo(map) :: Repo.t
  def parse_repo(data) do
    owner = data["owner"]["login"]
    name = data["name"]

    Repo.new(__MODULE__, owner, name)
  end

  @spec parse_merge_request(map) :: MergeRequest.t
  def parse_merge_request(data) do
    id = data["number"]

    MergeRequest.new(
      id,
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

  @spec parse_comment(map) :: Comment.t
  def parse_comment(data) do
    merge_request_id = data["issue"]["number"]
    sender = data["sender"]["login"]
    body = data["comment"]["body"]
    timestamp = data["comment"]["created_at"] |> NaiveDateTime.from_iso8601!

    Comment.new(merge_request_id, sender, body, timestamp)
  end
end
