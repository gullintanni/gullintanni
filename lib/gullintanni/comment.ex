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
end
