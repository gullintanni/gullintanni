defmodule Gullintanni.Pipeline do
  @moduledoc """
  Defines a Gullintanni build pipeline.

  A pipeline is uniquely identified by repository and encapsulates the state
  necessary to coordinate builds and merges.
  """

  alias __MODULE__, as: Pipeline
  alias Gullintanni.Config
  alias Gullintanni.Comment
  alias Gullintanni.Repo
  alias Gullintanni.Worker

  @typedoc "The pipeline reference"
  @type pipeline :: pid | {atom, node} | name

  @typedoc "The pipeline name"
  @type name :: atom
              | {:global, term}
              | {:via, module, term}

  @typedoc "The pipeline type"
  @type t ::
    %Pipeline{
      config: Config.t,
      repo: Repo.t,
      bot_name: String.t,
      merge_requests: map,
      worker: Worker.t
    }

  @enforce_keys [:repo]
  defstruct [
    config: [],
    repo: nil,
    bot_name: nil,
    merge_requests: %{},
    worker: nil
  ]

  @required_config_settings [:repo_provider, :repo_owner, :repo_name, :worker]

  @doc """
  Starts a new pipeline with the given `config` settings.
  """
  @spec start_link(Config.t) :: Agent.on_start | :error
  def start_link(config) do
    with {:ok, pipeline} <- new(config) do
      Agent.start_link(fn -> pipeline end, name: via_tuple(pipeline))
    end
  end

  defp via_tuple(pipeline) do
    {:via, :gproc, {:n, :l, {__MODULE__, identify(pipeline)}}}
  end

  @spec identify(t | Repo.t | String.t) :: String.t
  defp identify(%Pipeline{} = pipeline), do: identify(pipeline.repo)
  defp identify(%Repo{} = repo), do: identify("#{repo}")
  defp identify(name) when is_binary(name), do: name

  @doc """
  Returns the `pid` of a pipeline agent, or `:undefined` if no process is
  associated with the given `identifier`.
  """
  @spec whereis(t | Repo.t | String.t) :: pid | :undefined
  def whereis(identifier) do
    :gproc.where({:n, :l, {__MODULE__, identify(identifier)}})
  end

  # Creates a new pipeline with the given `config` settings.
  #
  # Returns `{:ok, pipeline}` if the configuration is valid, otherwise
  # `{:error, :invalid_config}`.
  @spec new(Config.t) :: {:ok, t} | {:error, :invalid_config}
  defp new(config) do
    with config = Config.parse_runtime_settings(config),
         true <- valid_config?(config),
         pipeline = from_config(config) do
      {:ok, pipeline}
    else
      _ -> {:error, :invalid_config}
    end
  end

  @doc """
  Returns `true` if all required pipeline configuration values exist in
  `config`, otherwise `false`.
  """
  @spec valid_config?(Config.t) :: boolean
  def valid_config?(config) do
    with true <- Config.settings_present?(@required_config_settings, config),
         true <- config[:repo_provider].valid_config?(config),
         true <- config[:worker].valid_config?(config) do
      true
    end
  end

  @spec from_config(Config.t) :: t
  defp from_config(config) do
    repo = Repo.new(config[:repo_provider], config[:repo_owner], config[:repo_name])
    bot_name = repo.provider.whoami(config)
    reqs =
      repo.provider.download_merge_requests(repo, config)
      |> Map.new(fn req -> {req.id, req} end)

    %Pipeline{
      config: config,
      repo: repo,
      bot_name: bot_name,
      merge_requests: reqs,
      worker: config[:worker]
    }
  end

  @spec handle_comment(pipeline, Comment.t) :: :ok
  def handle_comment(:undefined, _), do: :ok
  def handle_comment(pipeline, %Comment{} = comment) do
    # TODO: implement; this is a stub
    pipeline = Agent.get(pipeline, &(&1))
    merge_request = Map.get(pipeline.merge_requests, comment.merge_request_id)
    commands = Comment.parse_commands(comment, pipeline.bot_name)

    IO.inspect merge_request
    IO.inspect comment
    IO.inspect commands
    :ok
  end
end


defimpl Inspect, for: Gullintanni.Pipeline do
  import Inspect.Algebra

  def inspect(pipeline, _opts) do
    surround("#Pipeline<repo: ", "#{pipeline.repo}", ">")
  end
end
