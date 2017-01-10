defmodule Gullintanni.Workers.TravisCI do
  @moduledoc """
  Worker adapter module for Travis CI -- https://travis-ci.org/
  """

  alias Gullintanni.Config

  @behaviour Gullintanni.Worker

  @default_endpoint "https://api.travis-ci.org/"
  @display_name "Travis CI"
  @domain "travis-ci.org"
  @required_config_settings [:worker_auth_token]

  def display_name(), do: @display_name

  def domain(), do: @domain

  def valid_config?(config) do
    Config.settings_present?(@required_config_settings, config)
  end

  @spec client(Config.t) :: HardHat.Client.t
  defp client(config) do
    endpoint = config[:worker_endpoint] || @default_endpoint
    HardHat.Client.new(%{access_token: config[:worker_auth_token]}, endpoint)
  end

  def whoami(config) do
    HardHat.User.whoami(client(config)).login
  end
end
