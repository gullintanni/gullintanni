defmodule Gullintanni.Pipeline do
  @moduledoc """
  """

  alias __MODULE__, as: Pipeline
  alias Gullintanni.Provider
  alias Gullintanni.Queue
  alias Gullintanni.Repo

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
  """
  @spec load(name, config) :: t
  def load(name, opts \\ []) do
    config =
      load_config(name)
      |> Keyword.merge(opts)
      |> parse_runtime_settings()

    {provider, repo} = parse_config(config)

    %Pipeline{
      config: config,
      provider: provider,
      repo: repo,
      queue: Queue.new
    }
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
  Parses and validates a pipeline configuration.

  Raises an ArgumentError if there are missing settings.
  """
  @spec parse_config(config) :: {Provider.t, Repo.t}
  def parse_config(config) do
    required_keys = [:provider, :repo_owner, :repo_name]

    Enum.each(required_keys, fn key ->
      unless Keyword.has_key?(config, key),
        do: raise ArgumentError, "missing #{inspect key} configuration setting"
    end)

    provider = config[:provider]
    repo = Repo.new(config[:repo_owner], config[:repo_name])

    # dispatch to check for additional required keys
    provider.validate_config(config)

    {provider, repo}
  end

  @doc """
  Returns the provider's effective user identity.
  """
  @spec whoami(t) :: String.t
  def whoami(pipeline) do
    pipeline.provider.whoami(pipeline.config)
  end
end
