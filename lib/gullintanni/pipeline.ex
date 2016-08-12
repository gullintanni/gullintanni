defmodule Gullintanni.Pipeline do
  @moduledoc """
  """

  alias __MODULE__, as: Pipeline
  alias Gullintanni.MergeRequest
  alias Gullintanni.Provider
  alias Gullintanni.Queue
  alias Gullintanni.Repo
  require Logger

  @typedoc "A pipeline configuration name"
  @type name :: atom

  @typedoc "The raw pipeline configuration settings"
  @type config :: Keyword.t

  @typedoc "The pipeline type"
  @type t ::
    %Pipeline{
      config: config,
      provider: Provider.t,
      repo: Repo.t,
      queue: Queue.t
    }

  defstruct [:config, :provider, :repo, :queue]

  @doc """
  Creates a pipeline with settings loaded from the application configuration.

  The settings are loaded from the named pipeline's config, as set in the
  application configuration. Any options specified in `opts` will then override
  those settings.

  Returns `{:ok, pipeline}` if the configuration is valid, otherwise `:error`.
  """
  @spec load(name, config) :: {:ok, t} | :error
  def load(name, opts \\ []) when is_atom(name) do
    _ = Logger.info "loading #{inspect name} pipeline configuration"

    config =
      load_config(name)
      |> Keyword.merge(opts)
      |> parse_runtime_settings()

    case valid_config?(config) do
      true -> {:ok, new(config)}
      false -> :error
    end
  end

  # Returns the named pipeline config from the application configuration,
  # `[]` if no config was found.
  @spec load_config(name) :: config
  defp load_config(name) do
    with {:ok, pipelines} <- Application.fetch_env(:gullintanni, :pipeline),
         {:ok, config} <- Keyword.fetch(pipelines, name) do
      config
    else
      :error -> []
    end
  end

  # Transforms all the `{:system, "ENV_VAR"}` tuples into their respective
  # values grabbed from the process environment.
  @spec parse_runtime_settings(config) :: config
  defp parse_runtime_settings(config) do
    Enum.map(config, fn
      {key, {:system, env_var}} -> {key, System.get_env(env_var)}
      {key, value} -> {key, value}
    end)
  end

  @doc """
  Returns `true` if all required pipeline configuration values exist in
  `config`, otherwise `false`.
  """
  @spec valid_config?(config) :: boolean
  def valid_config?(config) do
    required_keys = [:provider, :repo_owner, :repo_name]

    answer =
      Enum.reduce(required_keys, true, fn(key, answer) ->
        case Keyword.has_key?(config, key) do
          true -> answer
          false ->
            _ = Logger.error "missing #{inspect key} configuration setting"
            false
        end
      end)

    # dispatch to check for additional required keys
    answer and config[:provider].valid_config?(config)
  end

  @spec new(config) :: t
  defp new(config) do
    %Pipeline{
      config: config,
      provider: config[:provider],
      repo: Repo.new(config[:repo_owner], config[:repo_name]),
      queue: Queue.new
    }
  end

  @doc """
  Returns the provider account's effective user identity.
  """
  @spec whoami(t) :: String.t
  def whoami(pipeline) do
    pipeline.provider.whoami(pipeline.config)
  end

  @doc """
  Initializes the pipeline's queue by downloading a list of the repository's
  open merge requests.

  This replaces any existing queue that may be stored in the pipeline.
  """
  @spec init_queue(t) :: t
  def init_queue(pipeline) do
    queue =
      pipeline
      |> download_merge_requests()
      |> Queue.new

    %{pipeline | queue: queue}
  end

  @doc """
  Downloads a list of the repository's open merge requests.
  """
  @spec download_merge_requests(t) :: [MergeRequest.t]
  def download_merge_requests(pipeline) do
    pipeline.provider.download_merge_requests(pipeline.repo, pipeline.config)
  end
end
