Socket
======

An [Elixir][] convenience library to define an Internet socket address.

[Elixir]: http://elixir-lang.org/

Overview
--------

A *socket address* is the combination of an IP address and a port number. This
can be used along with a transport protocol in order to define an endpoint of
a connection across a network.

### The Problem

When using the Erlang HTTP server [Cowboy][], either directly or indirectly via
[Plug][]/[Phoenix][]/etc., if you want to bind the listener to a specific IP
address, you must pass the address in a **tuple format**. For example, if you
want to bind to the localhost address of _127.0.0.1_, you must pass in the
tuple:

    {127, 0, 0, 1}

The required tuple format gets more confusing if you want to bind to an IPv6
address. For instance, the IPv6 address _FE80::204:ACFF:FE17:BF38_ must be
passed in as the tuple:

    {65152, 0, 0, 0, 516, 44287, 65047, 48952}

[Cowboy]: https://github.com/ninenines/cowboy
[Plug]: https://github.com/elixir-lang/plug
[Phoenix]: http://www.phoenixframework.org/

### The Solution

The Socket library helps ease the mental burden of figuring out Cowboy's
required tuple format by generating it for you based on normal IP address
strings. It sanity checks both the IP address and port number you give, and
then packages it into a struct for use when setting your listener options.

It's essentially a thin wrapper around the Erlang [`:inet.parse_address/1`][]
function.

[`:inet.parse_address/1`]: http://erlang.org/doc/man/inet.html#parse_address-1

Usage
-----

```elixir
iex> {:ok, socket} = Socket.new("127.0.0.1", 80)
iex> socket
#Socket<127.0.0.1:80>

iex> {:ok, socket} = Socket.new("fe80::204:acff:fe17:bf38", 80)
iex> socket
#Socket<[FE80::204:ACFF:FE17:BF38]:80>
iex> socket.ip
{65152, 0, 0, 0, 516, 44287, 65047, 48952}
iex> socket.port
80

iex> Socket.new("100.200.300.400", 80)
{:error, :invalid_ip_address}

iex> Socket.new("0.0.0.0", 99999)
{:error, :invalid_port}
```

License
-------

Socket is provided under the terms of the
[ISC License](https://en.wikipedia.org/wiki/ISC_license).

Copyright &copy; 2016, [Aaron Bull Schaefer](mailto:aaron@elasticdog.com).
