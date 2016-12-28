defmodule Gullintanni do
  @moduledoc """
  The Gullintanni Git merge bot application.
  """

  use Application
  alias Gullintanni.Config
  alias Gullintanni.Pipeline
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Gullintanni.Pipeline.Supervisor, []),
      worker(Task, [&load_configured_pipelines/0], restart: :temporary),
      supervisor(Gullintanni.Webhook.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Gullintanni.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp load_configured_pipelines do
    with true <- Config.load(:enable_load_pipelines) do
      Enum.each(Config.load(:pipeline), fn({name, config}) ->
        _ = Logger.info "loading #{inspect name} pipeline configuration"
        Pipeline.Supervisor.start_pipeline(config)
      end)
    end
  end
end
