defmodule Gullintanni.Pipeline do
  @moduledoc """
  Defines a Gullintanni build pipeline.

  A pipeline is uniquely identified by a provider plus a repository, and
  encapsulates the state necessary to coordinate builds and merges.
  """

  alias __MODULE__, as: Pipeline
  alias Gullintanni.Config
  alias Gullintanni.MergeRequest
  alias Gullintanni.Provider
  alias Gullintanni.Repo
  alias Gullintanni.Worker
  require Logger

  @typedoc "The pipeline type"
  @type t ::
    %Pipeline{
      config: Config.t,
      provider: Provider.t,
      repo: Repo.t,
      merge_requests: map,
      worker: Worker.t
    }

  defstruct [
    config: [],
    provider: nil,
    repo: nil,
    merge_requests: %{},
    worker: nil
  ]

  @doc """
  Creates a pipeline with settings loaded from the application configuration.

  The settings are loaded from the named pipeline's config, as set in the
  application configuration. Any options specified in `opts` will then override
  those settings.

  Returns `{:ok, pipeline}` if the configuration is valid, otherwise `:error`.
  """
  @spec load(atom, Keyword.t) :: {:ok, t} | :error
  def load(name, opts \\ []) when is_atom(name) do
    _ = Logger.info "loading #{inspect name} pipeline configuration"

    config =
      Config.load_config(:pipeline, name)
      |> Keyword.merge(opts)
      |> Config.parse_runtime_settings()

    case valid_config?(config) do
      true -> {:ok, new(config)}
      false -> :error
    end
  end

  @doc """
  Returns `true` if all required pipeline configuration values exist in
  `config`, otherwise `false`.
  """
  @spec valid_config?(Config.t) :: boolean
  def valid_config?(config) do
    answer =
      [:provider, :repo_owner, :repo_name, :worker]
      |> Config.settings_present?(config)

    # dispatch to check for additional required keys
    with true <- answer,
         true <- config[:provider].valid_config?(config),
         true <- config[:worker].valid_config?(config),
      do: true
  end

  @spec new(Config.t) :: t
  defp new(config) do
    %Pipeline{
      config: config,
      provider: config[:provider],
      repo: Repo.new(config[:repo_owner], config[:repo_name]),
      worker: config[:worker]
    }
  end

  @doc """
  Returns a string representation that uniquely identifies a `pipeline`.
  """
  @spec id(t) :: String.t
  def id(pipeline) do
    provider = pipeline.provider.__domain__
    repo = pipeline.repo
    "#{provider}/#{repo}"
  end

  @doc """
  Returns the provider account's effective user identity.
  """
  @spec whoami(t) :: String.t
  def whoami(pipeline) do
    pipeline.provider.whoami(pipeline.config)
  end

  @doc """
  Initializes the pipeline's merge requests by downloading a list of the
  repository's open MRs from its provider.

  This replaces any existing MRs that were stored in the pipeline.
  """
  @spec init_merge_requests(t) :: t
  def init_merge_requests(pipeline) do
    reqs =
      pipeline.provider.download_merge_requests(pipeline.repo, pipeline.config)
      |> Map.new(fn(req) -> {req.id, req} end)

    %{pipeline | merge_requests: reqs}
  end
end


defimpl Inspect, for: Gullintanni.Pipeline do
  import Inspect.Algebra
  alias Gullintanni.Pipeline

  def inspect(pipeline, _opts) do
    surround("#Pipeline<id: ", "#{inspect Pipeline.id(pipeline)}", ">")
  end
end
