defmodule Gullintanni.Comment do
  @moduledoc """
  Defines a comment.
  """

  alias __MODULE__, as: Comment
  alias Gullintanni.MergeRequest

  @type t ::
    %Comment{
      merge_request_id: MergeRequest.id,
      sender: String.t,
      body: String.t,
      timestamp: NaiveDateTime.t
    }

  defstruct [:merge_request_id, :sender, :body, :timestamp]

  @doc """
  Creates a new comment.
  """
  @spec new(MergeRequest.id, String.t, String.t, NaiveDateTime.t) :: t
  def new(merge_request_id, sender, body, timestamp) do
    %Comment{
      merge_request_id: merge_request_id,
      sender: sender,
      body: body,
      timestamp: timestamp
    }
  end

  @doc """
  Returns a list of recognized commands sent to `bot_name`.
  """
  @spec parse_commands(t, String.t) :: [atom]
  def parse_commands(%Comment{} = comment, bot_name) do
    mention = :binary.compile_pattern("@#{bot_name} ")

    comment.body
    |> String.split("\n")
    |> Stream.filter_map(&String.contains?(&1, mention), fn line ->
         # only keep the text after a mention
         line |> String.split(mention) |> List.last
       end)
    |> Stream.map(&parse_command/1)
    |> Enum.reject(&(&1 == :noop))
  end

  @spec parse_command(String.t) :: atom
  defp parse_command(line) do
     case String.split(line) do
       ["r+" | _rest] -> :approve
       ["r-" | _rest] -> :unapprove
       _ -> :noop
     end
  end
end
