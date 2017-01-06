defmodule HardHat.Response do
  @moduledoc """
  Defines a response to calls made to the Travis CI API.
  """

  defstruct [:raw, :data]

  @typedoc "The response type"
  @type t :: %__MODULE__{
    raw: HTTPoison.Response.t,
    data: any,
  }

  @spec parse({atom, HTTPoison.Response.t}) ::
  def parse({:error, raw_response}, _format) do
    {:error, raw_response}
  end
  def parse({:ok, raw_response}, format) do
    data = decode(raw_response, format)
    {:ok, %__MODULE__{raw: raw_response, data: data}}
  end

  @spec decode(HTTPoison.Response.t, any) :: any
  defp decode(%HTTPoison.Response{body: ""}, _format) do
    nil
  end
  defp decode(%HTTPoison.Response{body: body}, nil)do
    Poison.decode!(body)
  end
  defp decode(%HTTPoison.Response{body: body}, {key, format}) do
    Poison.decode!(body, as: %{key => [format]}) |> Map.get(key)
  end
  defp decode(%HTTPoison.Response{body: body}, format) do
    Poison.decode!(body, as: format)
  end
end
