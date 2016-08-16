defmodule Gullintanni.Pipeline.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_pipeline(config) do
    Supervisor.start_child(__MODULE__, [config])
  end

  def init(_) do
    children = [
      worker(Gullintanni.Pipeline, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
