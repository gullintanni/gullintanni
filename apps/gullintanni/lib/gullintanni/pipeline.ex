defmodule Gullintanni.Pipeline do
  @moduledoc """
  Defines a Gullintanni build pipeline.

  A pipeline is uniquely identified by repository and encapsulates the state
  necessary to coordinate builds and merges.
  """

  alias __MODULE__, as: Pipeline
  alias Gullintanni.Config
  alias Gullintanni.Comment
  alias Gullintanni.MergeRequest
  alias Gullintanni.Repo
  alias Gullintanni.Worker

  require Logger

  @typep command :: :approve | :unapprove | :noop

  @typedoc "The pipeline reference"
  @type pipeline :: pid | {atom, node} | name

  @typedoc "The pipeline name"
  @type name :: atom | {:global, term} | {:via, module, term}

  @typedoc "The pipeline type"
  @type t :: %Pipeline{
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
  @spec start_link(Config.t) :: Agent.on_start
  def start_link(config) do
    with {:ok, pipeline} <- new(config) do
      Agent.start_link(fn -> pipeline end, name: via_tuple(pipeline))
    end
  end

  defp via_tuple(pipeline) do
    {:via, Registry, {Gullintanni.Registry, identify(pipeline)}}
  end

  @spec identify(t | Repo.t | String.t) :: String.t
  defp identify(%Pipeline{} = pipeline), do: identify(pipeline.repo)
  defp identify(%Repo{} = repo), do: identify("#{repo}")
  defp identify(name) when is_binary(name), do: name

  @doc """
  Returns the `pid` of a pipeline agent, or `:undefined` if no process is
  associated with the given `identifier`.
  """
  @spec whereis(pid | atom | t | Repo.t | String.t) :: pid | :undefined
  def whereis(identifier) when is_pid(identifier), do: identifier
  def whereis(identifier) when is_atom(identifier), do: :undefined
  def whereis(identifier) do
    case Registry.lookup(Gullintanni.Registry, identify(identifier)) do
      [{pid, _value}] -> pid
      _ -> :undefined
    end
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
    merge_reqs =
      repo
      |> repo.provider.download_merge_requests(config)
      |> Map.new(fn merge_req -> {merge_req.id, merge_req} end)

    %Pipeline{
      config: config,
      repo: repo,
      bot_name: bot_name,
      merge_requests: merge_reqs,
      worker: config[:worker]
    }
  end

  @doc """
  Gets the current state of a `pipeline`.
  """
  @spec get(pipeline) :: t | :undefined
  def get(pipeline) do
    case whereis(pipeline) do
      :undefined -> :undefined
      pid -> Agent.get(pid, &(&1))
    end
  end

  @doc """
  Gets a value from a `pipeline` by `key`.
  """
  @spec get(pipeline, atom) :: any | :undefined
  def get(pipeline, key) do
    case whereis(pipeline) do
      :undefined -> :undefined
      pid -> Agent.get(pid, &Map.get(&1, key))
    end
  end

  @spec fetch(pipeline) :: {:ok, t} | :error
  defp fetch(pipeline) do
    case get(pipeline) do
      :undefined -> :error
      pipeline -> {:ok, pipeline}
    end
  end

  @doc """
  Puts the `value` for the given `key` in the `pipeline`.
  """
  @spec put(pipeline, any, any) :: :ok
  def put(pipeline, key, value) do
    Agent.update(whereis(pipeline), &Map.put(&1, key, value))
  end

  @doc """
  Returns `true` if the user is an authorized reviewer on `pipeline`.
  """
  @spec authorized?(pipeline, String.t) :: boolean
  def authorized?(_pipeline, _username) do
    # TODO: implement; this is a stub
    true
  end

  @spec handle_comment(pipeline, Comment.t) :: :ok
  def handle_comment(pipeline, %Comment{} = comment) do
    case parse_commands(comment.body, get(pipeline, :bot_name)) do
      [] -> :ok
      commands -> handle_commands(pipeline, comment, commands)
    end
  end

  # Returns a list of recognized commands sent to `bot_name`.
  @spec parse_commands(String.t, String.t) :: [command]
  defp parse_commands(text, bot_name) do
    mention = :binary.compile_pattern("@#{bot_name} ")

    text
    |> String.split("\n")
    |> Stream.filter_map(&String.contains?(&1, mention), fn line ->
         # only parse the text after a mention
         line
         |> String.split(mention)
         |> List.last
         |> parse_command()
       end)
    |> Enum.reject(&(&1 == :noop))
  end

  @spec parse_command(String.t) :: command
  defp parse_command(line) do
     case String.split(line) do
       ["r+" | _rest] -> :approve
       ["r-" | _rest] -> :unapprove
       _ -> :noop
     end
  end

  defp handle_commands(pipeline, comment, commands) do
    case authorized?(pipeline, comment.sender) do
      true -> _handle_commands(pipeline, comment, commands)
      false -> :ok
    end
  end

  defp _handle_commands(pipeline, comment, [:approve]) do
    with {:ok, pipeline} <- fetch(pipeline),
         {:ok, old_merge_req} <- Map.fetch(pipeline.merge_requests, comment.merge_request_id) do
      merge_req =
        old_merge_req
        |> MergeRequest.approve(comment.sender, comment.timestamp)

      # suppress notifications if there was no state change
      unless merge_req == old_merge_req do
        merge_reqs = Map.put(pipeline.merge_requests, merge_req.id, merge_req)

        put(pipeline, :merge_requests, merge_reqs)

        # send notifications
        message = "commit #{merge_req.latest_commit} has been approved by @#{comment.sender}"
        pipeline.repo.provider.post_comment(
          pipeline.repo,
          merge_req.id,
          ":+1: " <> message,
          pipeline.config
        )
        _ = Logger.info message <> " on #{merge_req.url}"
      end
      :ok
    else
      _ -> :ok
    end
  end
  defp _handle_commands(pipeline, comment, [:unapprove]) do
    with {:ok, pipeline} <- fetch(pipeline),
         {:ok, old_merge_req} <- Map.fetch(pipeline.merge_requests, comment.merge_request_id) do
      merge_req =
        old_merge_req
        |> MergeRequest.unapprove(comment.sender)

      # suppress notifications if there was no state change
      unless merge_req == old_merge_req do
        merge_reqs = Map.put(pipeline.merge_requests, merge_req.id, merge_req)

        put(pipeline, :merge_requests, merge_reqs)

        # send notifications
        message = "approval has been cancelled by @#{comment.sender}"
        pipeline.repo.provider.post_comment(
          pipeline.repo,
          merge_req.id,
          ":broken_heart: " <> message,
          pipeline.config
        )
        _ = Logger.info message <> " on #{merge_req.url}"
      end
      :ok
    else
      _ -> :ok
    end
  end
  defp _handle_commands(_pipeline, _comment, commands) do
    # catch-all clause
    Logger.debug "unhandled commands #{inspect commands}"
  end

  @spec handle_push(pipeline, MergeRequest.id, MergeRequest.sha) :: :ok
  def handle_push(pipeline, merge_req_id, sha) do
    with {:ok, pipeline} <- fetch(pipeline),
         {:ok, merge_req} <- Map.fetch(pipeline.merge_requests, merge_req_id) do
      merge_req = MergeRequest.update_sha(merge_req, sha)
      merge_reqs = Map.put(pipeline.merge_requests, merge_req.id, merge_req)

      put(pipeline, :merge_requests, merge_reqs)

      # send notifications
      message = "commit #{merge_req.latest_commit} was pushed to branch #{merge_req.branch_name}"
      _ = Logger.info message <> " on #{merge_req.url}"
      :ok
    else
      _ -> :ok
    end
  end

  @spec handle_merge_request_open(pipeline, MergeRequest.t) :: :ok
  def handle_merge_request_open(pipeline, merge_req) do
    with {:ok, pipeline} <- fetch(pipeline) do
      merge_reqs = Map.put_new(pipeline.merge_requests, merge_req.id, merge_req)

      put(pipeline, :merge_requests, merge_reqs)

      # send notifications
      message = "opened merge request #{merge_req.url}"
      _ = Logger.info message
      :ok
    else
      _ -> :ok
    end
  end

  @spec handle_merge_request_close(pipeline, MergeRequest.id) :: :ok
  def handle_merge_request_close(pipeline, merge_req_id) do
    with {:ok, pipeline} <- fetch(pipeline),
         {:ok, merge_req} <- Map.fetch(pipeline.merge_requests, merge_req_id) do
      merge_reqs = Map.delete(pipeline.merge_requests, merge_req.id)

      put(pipeline, :merge_requests, merge_reqs)

      # send notifications
      message = "closed merge request #{merge_req.url}"
      _ = Logger.info message
      :ok
    else
      _ -> :ok
    end
  end
end


defimpl Inspect, for: Gullintanni.Pipeline do
  import Inspect.Algebra

  def inspect(pipeline, _opts) do
    surround("#Pipeline<repo: ", "#{pipeline.repo}", ">")
  end
end
