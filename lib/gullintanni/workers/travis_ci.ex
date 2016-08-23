defmodule Gullintanni.Workers.TravisCI do
  @moduledoc """
  Worker adapter module for Travis CI -- https://travis-ci.org/
  """

  @behaviour Gullintanni.Worker

  @display_name "Travis CI"
  @domain "travis-ci.org"

  def __display_name__, do: @display_name
  def __domain__, do: @domain

  def valid_config?(_config) do
    # TODO: implement; this is a stub
    true
  end
end
