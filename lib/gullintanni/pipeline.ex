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

  @enforce_keys [:repo]
  defstruct [
    config: [],
    repo: nil,
    merge_requests: %{},
    worker: nil
  ]

  @required_config_settings [:repo_provider, :repo_owner, :repo_name, :worker]

  @doc """
  Starts an agent linked to the current process to cache pipeline data.
  """
  @spec start_link(Config.t) :: Agent.on_start | :error
  def start_link(config) do
    with {:ok, pipeline} <- new(config) do
      Agent.start_link(fn -> pipeline end, name: via_tuple(pipeline))
    end
  end

  # Returns a gproc via tuple for identifying pipeline Agents.
  defp via_tuple(identifier) do
    {:via, :gproc, gproc_key(identifier)}
  end

  # Returns a key for identifying pipelines in the gproc extended process
  # registry.
  #
  # * type ':n` means 'name' and is unique within the given context
  # * scope `:l` means the 'local' context
  defp gproc_key(%Pipeline{} = pipeline), do: gproc_key(pipeline.repo)
  defp gproc_key(%Repo{} = repo), do: gproc_key("#{repo}")
  defp gproc_key(name) when is_binary(name) do
    {:n, :l, {__MODULE__, name}}
  end

  # Returns the pid of the specified pipeline's agent.
  #
  # Returns `:undefined` if no process is registered with the given key.
  def __whereis__(identifier) do
    :gproc.where(gproc_key(identifier))
  end

  @doc """
  Creates a new pipeline with the given `config` settings.

  Returns `{:ok, pipeline}` if the configuration is valid, otherwise `:error`.
  """
  @spec new(Config.t) :: {:ok, t} | :error
  def new(config) do
    with config = Config.parse_runtime_settings(config),
         true <- valid_config?(config),
         repo = Repo.new(config[:repo_provider], config[:repo_owner], config[:repo_name]),
         pipeline = %Pipeline{config: config, repo: repo, worker: config[:worker]} do
      {:ok, pipeline}
    else
      _ -> :error
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

  @doc """
  Loads pipeline settings from the named application configuration.

  Any options specified in `opts` will then override those settings.
  """
  @spec load_config(atom, Keyword.t) :: Config.t
  def load_config(name, opts \\ []) when is_atom(name) do
    _ = Logger.info "loading #{inspect name} pipeline configuration"

    Config.load(:pipeline, name) |> Keyword.merge(opts)
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
