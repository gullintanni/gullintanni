defmodule HardHat do
  @moduledoc """
  A simple wrapper for the [Travis CI API](https://docs.travis-ci.com/api/).
  """

  alias HardHat.Client
  alias HardHat.Response
  require Logger

  @request_headers [
    {"Accept", "application/vnd.travis-ci.2+json"},
    {"Content-Type", "application/json"},
    {"User-Agent", "HardHat/#{Mix.Project.config[:version]}"},
  ]

  @doc """
  Issues an authenticated GET request to the given Travis CI API `path`.

  Returns `{:ok, response}` if the request was successful, otherwise
  `{:error, reason}`.
  """
  @spec get(Client.t, String.t, list) :: HardHat.Response.t
  def get(%Client{} = client, path, params \\ []) do
    __request__(client, :get, url(client, path, params))
  end

  @doc """
  Issues an authenticated POST request to the given Travis CI API `path`.

  Returns `{:ok, response}` if the request was successful, otherwise
  `{:error, reason}`.
  """
  @spec post(Client.t, String.t, HTTPoison.body) :: HardHat.Response.t
  def post(%Client{} = client, path, body \\ "") do
    __request__(client, :post, url(client, path), body)
  end

  @doc """
  Issues an authenticated PUT request to the given Travis CI API `path`.

  Returns `{:ok, response}` if the request was successful, otherwise
  `{:error, reason}`.
  """
  @spec put(Client.t, String.t, HTTPoison.body) :: HardHat.Response.t
  def put(%Client{} = client, path, body \\ "") do
    __request__(client, :put, url(client, path), body)
  end

  @doc false
  @spec __request__(Client.t, atom, String.t, HTTPoison.body) :: HardHat.Response.t
  def __request__(%Client{} = client, method, url, body \\ "") do
    _ = Logger.debug("#{method} #{url}")
    res = HTTPoison.request!(method, url, body, headers(client))

    %Response{body: res.body, status_code: res.status_code}
  end

  @spec url(Client.t, String.t, keyword) :: String.t
  defp url(%Client{endpoint: endpoint}, path, params \\ []) do
    endpoint <> path |> append_params(params)
  end

  # Appends query string parameters to the given `url`.
  @spec append_params(String.t, keyword) :: String.t
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
    @request_headers ++ authorization_header(client.auth)
  end

  # https://docs.travis-ci.com/api/#authentication
  @spec authorization_header(Client.auth) :: list
  defp authorization_header(%{access_token: token}) do
    [{"Authorization", ~s(token "#{token}")}]
  end
end
