defmodule Gullintanni.Workers.TravisCI do
  @moduledoc """
  Worker adapter module for Travis CI - https://travis-ci.org/
  """

  @behaviour Gullintanni.Worker

  def valid_config?(_config) do
    # TODO: implement; this is a stub
    true
  end
end
