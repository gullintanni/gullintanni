defmodule Socket do
  @moduledoc """
  Defines an Internet socket address.

  A *socket address* is the combination of an IP address and a port number.
  This can be used along with a transport protocol in order to define an
  endpoint of a connection across a network.
  """

  @typedoc "The IP address of a socket"
  @type ip_address :: String.t | char_list | :inet.ip_address

  @typedoc "The port number of a socket"
  @type port_number :: 0..65_535

  @typedoc "The socket address type"
  @type t :: %Socket{ip: :inet.ip_address, port: port_number}

  @enforce_keys [:ip, :port]
  defstruct [:ip, :port]

  @valid_ports 0..65_535

  @doc """
  Creates a new socket address with the given `ip` and `port`.

  Returns `{:ok, socket}` if the IP address and port number are valid, returns
  `{:error, reason}` otherwise. A valid IP address is anything that can be
  parsed by `:inet.parse_address/1`, and a valid port must be an integer in the
  range of `#{inspect @valid_ports}`.

  ## Examples

      iex> {:ok, socket} = Socket.new("0.0.0.0", 80)
      iex> socket
      #Socket<0.0.0.0:80>

      iex> {:ok, socket} = Socket.new("fe80::204:acff:fe17:bf38", 80)
      iex> socket
      #Socket<[FE80::204:ACFF:FE17:BF38]:80>

      iex> Socket.new("100.200.300.400", 80)
      {:error, :invalid_ip_address}

      iex> Socket.new("0.0.0.0", 99999)
      {:error, :invalid_port}
  """
  @spec new(ip_address, port_number) :: {:ok, t} | {:error, :invalid_ip_address | :invalid_port}
  def new(ip, port) do
    ip_address = parse(ip)

    cond do
      ip_address == nil ->
        {:error, :invalid_ip_address}
      Enum.member?(@valid_ports, port) == false ->
        {:error, :invalid_port}
      true ->
        {:ok, %Socket{ip: ip_address, port: port}}
    end
  end

  # Parses an `t:ip_address/0` into an `t::inet.ip_address/0` tuple.
  #
  # Returns `nil` if there was an error with parsing.
  @spec parse(ip_address) :: :inet.ip_address | nil
  defp parse(ip_address) when is_binary(ip_address) do
    ip_address |> String.to_char_list |> parse
  end
  defp parse(ip_address) when is_list(ip_address) do
    case :inet.parse_address(ip_address) do
      {:ok, value} -> value
      {:error, :einval} -> nil
    end
  end
  defp parse(ip_address) when is_tuple(ip_address) do
    try do
      :inet.ntoa(ip_address)
    rescue
      ArgumentError -> nil
    else
      {:error, :einval} -> nil
      _ -> ip_address
    end
  end
  defp parse(_), do: nil
end


defimpl Inspect, for: Socket do
  import Inspect.Algebra

  def inspect(socket, _opts) do
    surround("#Socket<", "#{socket}", ">")
  end
end


defimpl String.Chars, for: Socket do
  def to_string(socket) do
    case tuple_size(socket.ip) do
      4 -> "#{:inet.ntoa(socket.ip)}:#{socket.port}"
      8 -> "[#{:inet.ntoa(socket.ip)}]:#{socket.port}"
    end
  end
end
