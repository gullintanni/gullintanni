defmodule Gullintanni.Listener.Socket do
  @moduledoc """
  Utility module for handling TCP socket parsing and validation.
  """

  alias __MODULE__, as: Socket

  @typedoc "The IP address of a socket"
  @type address :: String.t | char_list | :inet.ip_address

  @typedoc "The port number of a socket"
  @type port_number :: 0..65535

  @typedoc "The socket type"
  @type t :: %Socket{address: address, port: port_number}

  @enforce_keys [:address, :port]
  defstruct [:address, :port]

  @valid_ports 0..65535

  @doc """
  Creates a new socket with the given `address` and `port`.

  Returns `{:ok, socket}` if the address and port are valid, returns
  `{:error, reason}` otherwise. A valid address is anything that can be parsed
  by `:inet.parse_address/1`, and a valid port must be an integer in the range
  of `#{inspect @valid_ports}`.

  ## Examples

      iex> {:ok, socket} = Gullintanni.Listener.Socket.new("0.0.0.0", 80)
      iex> socket
      #Socket<0.0.0.0:80>

      iex> {:ok, socket} = Gullintanni.Listener.Socket.new("fe80::204:acff:fe17:bf38", 80)
      iex> socket
      #Socket<[FE80::204:ACFF:FE17:BF38]:80>

      iex> Gullintanni.Listener.Socket.new("100.200.300.400", 80)
      {:error, :invalid_address}

      iex> Gullintanni.Listener.Socket.new("0.0.0.0", 99999)
      {:error, :invalid_port}
  """
  @spec new(address, port_number) :: {:ok, t} | {:error, :invalid_address} | {:error, :invalid_port}
  def new(address, port) do
    address = parse(address)

    cond do
      address == nil ->
        {:error, :invalid_address}
      Enum.member?(@valid_ports, port) == false ->
        {:error, :invalid_port}
      true ->
        {:ok, %Socket{address: address, port: port}}
    end
  end

  # Parses a string into an IP address tuple.
  @spec parse(address) :: :inet.ip_address | nil
  defp parse(address) when address |> is_binary do
    address
    |> String.to_char_list
    |> parse
  end
  defp parse(address) when address |> is_list do
    case :inet.parse_address(address) do
      {:ok, ip_address} -> ip_address
      {:error, :einval} -> nil
    end
  end
  defp parse(address) do
    address
  end
end


defimpl Inspect, for: Gullintanni.Listener.Socket do
  import Inspect.Algebra

  def inspect(socket, _opts) do
    surround("#Socket<", "#{socket}", ">")
  end
end


defimpl String.Chars, for: Gullintanni.Listener.Socket do
  def to_string(socket) do
    case tuple_size(socket.address) do
      4 -> "#{:inet.ntoa(socket.address)}:#{socket.port}"
      8 -> "[#{:inet.ntoa(socket.address)}]:#{socket.port}"
    end
  end
end
