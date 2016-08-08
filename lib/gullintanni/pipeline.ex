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
  Creates a new pipeline.

  The settings are loaded from the named pipeline's keyword list set in the
  application configuration. Any options set in `opts` will then override those
  settings.
  """
  @spec new(name, Keyword.t) :: t
  def new(name, opts \\ []) do
    {config, provider, repo} = parse_config(name, opts)

    %Pipeline{
      config: config,
      provider: provider,
      repo: repo,
      queue: Queue.new
    }
  end

  @doc """
  Returns the provider's effective user identity.
  """
  @spec whoami(t) :: String.t
  def whoami(pipeline) do
    pipeline.provider.whoami(pipeline.config)
  end

  # Parses and validates the pipeline configuration.
  #
  # Raises an ArgumentError if there are missing settings.
  @spec parse_config(name, Keyword.t) :: {config, Provider.t, Repo.t}
  defp parse_config(name, opts \\ []) do
    config =
      with {:ok, pipelines} <- Application.fetch_env(:gullintanni, :pipeline),
           {:ok, config} <- Keyword.fetch(pipelines, name) do
        config
        |> Keyword.merge(opts)
        |> parse_runtime_config()
      else
        :error -> []
      end

    if config[:provider],
      do: config[:provider].validate_config(config),
      else: raise_missing(name, :provider)

    repo =
      cond do
        !config[:repo_owner] -> raise_missing(name, :repo_owner)
        !config[:repo_name] -> raise_missing(name, :repo_name)
        true -> Repo.new(config[:repo_owner], config[:repo_name])
      end

    {config, config[:provider], repo}
  end

  # Parses the pipeline configuration at run time.
  #
  # This function will transform all the `{:system, "ENV_VAR"}` tuples into their
  # respective values grabbed from the process environment.
  @spec parse_runtime_config(config) :: config
  defp parse_runtime_config(config) do
    Enum.map(config, fn
      {key, {:system, env_var}} -> {key, System.get_env(env_var)}
      {key, value} -> {key, value}
    end)
  end

  @spec raise_missing(atom, atom) :: no_return
  defp raise_missing(pipeline, setting) do
      raise ArgumentError, "missing #{inspect setting} configuration in " <>
                           "config :gullintanni, :pipeline, #{inspect pipeline}"
  end
end
