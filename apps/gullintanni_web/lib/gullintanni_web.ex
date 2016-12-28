defmodule GullintanniWeb do
  @moduledoc """
  The Gullintanni Web frontend application.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(GullintanniWeb.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: GullintanniWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
