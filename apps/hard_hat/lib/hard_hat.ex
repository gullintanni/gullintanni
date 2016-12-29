defmodule HardHat do
  @moduledoc """
  A simple wrapper for the [Travis CI API](https://docs.travis-ci.com/api/).
  """

  alias HardHat.Client

  @typedoc "The response to an HTTP request."
  @type response :: map | {status_code, binary}

  @typedoc "The HTTP status code."
  @type status_code :: integer

  @typep method :: :get | :post | :put

  @user_agent [{"User-agent", "HardHat/#{Mix.Project.config[:version]}"}]

  @content_negotiation [
    {"Accept", "application/vnd.travis-ci.2+json"},
    {"Content-Type", "application/json"},
  ]

  @doc """
  Issues an authenticated GET request to the given Travis CI API `path`.

  Returns the decoded response body if the request was successful, otherwise
  `{status_code, body}`. Raises an exception in case of failure.
  """
  @spec get(Client.t, String.t) :: response
  def get(%Client{} = client, path) do
    request(:get, client, path)
  end

  @doc """
  Issues an authenticated POST request to the given Travis CI API `path`.

  Returns the decoded response body if the request was successful, otherwise
  `{status_code, body}`. Raises an exception in case of failure.
  """
  @spec post(Client.t, String.t, HTTPoison.body) :: response
  def post(%Client{} = client, path, body \\ "") do
    request(:post, client, path, body)
  end

  @doc """
  Issues an authenticated PUT request to the given Travis CI API `path`.

  Returns the decoded response body if the request was successful, otherwise
  `{status_code, body}`. Raises an exception in case of failure.
  """
  @spec put(Client.t, String.t, HTTPoison.body) :: response
  def put(%Client{} = client, path, body \\ "") do
    request(:put, client, path, body)
  end

  @spec request(method, Client.t, String.t, HTTPoison.body) :: response
  defp request(method, %Client{} = client, path, body \\ "") do
    url = client.endpoint <> path
    HTTPoison.request!(method, url, body, headers(client)) |> process_response
  end

  # https://docs.travis-ci.com/api/#making-requests
  @spec headers(Client.t) :: list
  defp headers(%Client{} = client) do
    @user_agent ++ @content_negotiation ++ authorization_header(client.auth)
  end

  # https://docs.travis-ci.com/api/#authentication
  @spec authorization_header(Client.auth) :: list
  defp authorization_header(%{access_token: token}) do
    [{"Authorization", ~s(token "#{token}")}]
  end

  @spec process_response(HTTPoison.Response.t) :: response
  defp process_response(%HTTPoison.Response{} = response) do
    case response.status_code do
      200 -> Poison.decode!(response.body)
      _ -> {response.status_code, response.body}
    end
  end
end
