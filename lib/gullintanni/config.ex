defmodule Gullintanni.Config do
  @moduledoc """
  Utility module for dealing with application configuration settings.
  """

  require Logger

  @typedoc "The configuration settings type"
  @type t :: Keyword.t

  @doc """
  Returns `true` if all of the `keys` are present in the `config`, otherwise
  `false`.

  Logs an error for any missing settings.
  """
  @spec settings_present?([atom], t) :: boolean
  def settings_present?(keys, config) do
    Enum.reduce(keys, true, fn(key, answer) ->
      case Keyword.has_key?(config, key) do
        true -> answer
        false ->
          _ = Logger.error "missing #{inspect key} configuration setting"
          false
      end
    end)
  end

  @doc """
  Returns the value of the application configuration specified by `key`.

  Returns `[]` if no configuration was found.
  """
  @spec load(atom, t) :: t
  def load(key) when is_atom(key) do
    Application.get_env(:gullintanni, key, [])
  end

  @doc """
  Returns the value of the `subkey` of the parent application configuration
  specified by `key`.

  Returns `[]` if no configuration was found.
  """
  @spec load(atom, atom) :: t
  def load(key, subkey) when is_atom(subkey) do
    key
    |> load()
    |> Keyword.get(subkey, [])
  end

  @doc """
  Transforms all the `{:system, "ENV_VAR"}` tuples into their respective values
  grabbed from the process environment.
  """
  @spec parse_runtime_settings(t) :: t
  def parse_runtime_settings(config) do
    Enum.map(config, fn
      {key, {:system, env_var}} -> {key, System.get_env(env_var)}
      {key, value} -> {key, value}
    end)
  end
end
