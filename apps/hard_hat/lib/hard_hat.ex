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
  @spec get(Client.t, String.t, list) :: response
  def get(%Client{} = client, path, params \\ []) when is_binary(path) do
    url = client.endpoint <> path |> append_params(params)
    HTTPoison.get!(url, headers(client)) |> process_response
  end

  @doc """
  Issues an authenticated POST request to the given Travis CI API `path`.

  Returns the decoded response body if the request was successful, otherwise
  `{status_code, body}`. Raises an exception in case of failure.
  """
  @spec post(Client.t, String.t, HTTPoison.body) :: response
  def post(%Client{} = client, path, body \\ "") when is_binary(path) do
    url = client.endpoint <> path
    HTTPoison.post!(url, body, headers(client)) |> process_response
  end

  @doc """
  Issues an authenticated PUT request to the given Travis CI API `path`.

  Returns the decoded response body if the request was successful, otherwise
  `{status_code, body}`. Raises an exception in case of failure.
  """
  @spec put(Client.t, String.t, HTTPoison.body) :: response
  def put(%Client{} = client, path, body \\ "") when is_binary(path) do
    url = client.endpoint <> path
    HTTPoison.put!(url, body, headers(client)) |> process_response
  end

  @doc false
  @spec __request__(Client.t, method, String.t, HTTPoison.body)
    :: HTTPoison.Response.t
  def __request__(%Client{} = client, method, path, body \\ "")
      when is_binary(path) do
    url = client.endpoint <> path
    HTTPoison.request!(method, url, body, headers(client))
  end

  @doc false
  @spec __normalize__(String.t) :: String.t
  def __normalize__(path) when is_binary(path) do
    if String.ends_with?(path, "/") do
      path
    else
      path <> "/"
    end
  end

  # Appends query string parameters to the given `url`.
  @spec append_params(String.t, term) :: String.t
  defp append_params(url, params) do
    _append_params(URI.parse(url), params)
  end

  @spec _append_params(URI.t, list) :: URI.t
  defp _append_params(%URI{} = uri, []) do
    uri
  end
  defp _append_params(%URI{query: nil} = uri, params) do
    Map.put(uri, :query, URI.encode_query(params))
  end
  defp _append_params(%URI{} = uri, params) do
    {_, new_uri} =
      Map.get_and_update(uri, :query, fn current_value ->
        new_value = current_value <> "&" <> URI.encode_query(params)
        {current_value, new_value}
      end)

    new_uri
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
