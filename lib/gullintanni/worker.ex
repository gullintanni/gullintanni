defmodule Gullintanni.Worker do
  @moduledoc """
  This module specifies the API that a worker is required to implement.

  Workers are adapter modules that interface with a CI service.
  """

  @type config :: Keyword.t
  @type t :: module

  @doc """
  Returns `true` if all required worker configuration values exist in `config`,
  otherwise `false`.
  """
  @callback valid_config?(config) :: boolean
end
