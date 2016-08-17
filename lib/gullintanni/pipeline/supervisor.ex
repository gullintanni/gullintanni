alias Experimental.DynamicSupervisor

defmodule Gullintanni.Pipeline.Supervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_pipeline(config) do
    DynamicSupervisor.start_child(__MODULE__, [config])
  end

  def init(_) do
    children = [
      worker(Gullintanni.Pipeline, [], restart: :transient)
    ]

    {:ok, children, strategy: :one_for_one}
  end
end
