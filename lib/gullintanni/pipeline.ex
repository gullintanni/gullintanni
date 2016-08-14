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
  require Logger

  @typedoc "The pipeline type"
  @type t ::
    %Pipeline{
      config: Config.t,
      repo: Repo.t,
      merge_requests: map,
      worker: Worker.t
    }

  defstruct [
    config: [],
    repo: nil,
    merge_requests: %{},
    worker: nil
  ]

  # Returns an atom representation that uniquely identifies a `pipeline`.
  @spec __id__(t) :: atom
  def __id__(pipeline), do: String.to_atom("#{pipeline.repo}")

  @doc """
  Starts an agent linked to the current process to cache pipeline data.
  """
  @spec start_link(t) :: Agent.on_start
  def start_link(pipeline) do
    Agent.start_link(fn -> pipeline end, name: __id__(pipeline))
  end

  @doc """
  Creates a new pipeline with the given `config` settings.

  Returns `{:ok, pipeline}` if the configuration is valid, otherwise `:error`.
  """
  @spec new(Config.t) :: {:ok, t} | :error
  def new(config) do
    case valid_config?(config) do
      true -> {:ok, _new(config)}
      false -> :error
    end
  end

  @spec _new(Config.t) :: t
  defp _new(config) do
    repo = Repo.new(config[:repo_provider], config[:repo_owner], config[:repo_name])

    %Pipeline{
      config: config,
      repo: repo,
      worker: config[:worker]
    }
  end

  @doc """
  Returns `true` if all required pipeline configuration values exist in
  `config`, otherwise `false`.
  """
  @spec valid_config?(Config.t) :: boolean
  def valid_config?(config) do
    answer =
      [:repo_provider, :repo_owner, :repo_name, :worker]
      |> Config.settings_present?(config)

    # dispatch to check for additional required keys
    with true <- answer,
         true <- config[:repo_provider].valid_config?(config),
         true <- config[:worker].valid_config?(config),
      do: true
  end

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

    Config.load_config(:pipeline, name)
    |> Keyword.merge(opts)
    |> Config.parse_runtime_settings()
    |> new()
  end

  @doc """
  Returns the provider account's effective user identity.
  """
  @spec whoami(t) :: String.t
  def whoami(pipeline) do
    pipeline.repo.provider.whoami(pipeline.config)
  end

  @doc """
  Initializes the pipeline's merge requests by downloading a list of the
  repository's open MRs.

  This replaces any existing MRs that were stored in the pipeline.
  """
  @spec init_merge_requests(t) :: t
  def init_merge_requests(pipeline) do
    reqs =
      pipeline.repo.provider.download_merge_requests(pipeline.repo, pipeline.config)
      |> Map.new(fn(req) -> {req.id, req} end)

    %{pipeline | merge_requests: reqs}
  end

  @spec handle_comment(Comment.t, Repo.t) :: :ok
  def handle_comment(%Comment{} = comment, repo) do
    # TODO: implement; this is a stub
    :ok
  end
end


defimpl Inspect, for: Gullintanni.Pipeline do
  import Inspect.Algebra

  def inspect(pipeline, _opts) do
    surround("#Pipeline<repo: ", "#{pipeline.repo}", ">")
  end
end
