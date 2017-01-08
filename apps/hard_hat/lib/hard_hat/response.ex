defmodule HardHat.Response do
  @moduledoc """
  Defines an HTTP response to calls made to the Travis CI API.
  """

  defstruct [:body, :status_code]

  @typedoc "The response type"
  @type t :: %__MODULE__{
    body: binary,
    status_code: integer,
  }

  @spec parse(t, any) :: {:ok, any} | {:error, any}
  def parse(response, format \\ nil)
  def parse(%__MODULE__{status_code: status_code} = response, format)
      when status_code in 200..299 do
    {:ok, decode(response.body, format)}
  end
  def parse(%__MODULE__{} = response, _format) do
    {:error, decode(response.body, nil)}
  end

  defp decode("", _format) do
    nil
  end
  defp decode(body, nil) do
    Poison.decode!(body)
  end
  defp decode(body, format) do
    Poison.decode!(body, as: format)
  end
end
