defmodule Gullintanni.Comment do
  @moduledoc """
  Defines an incoming comment from a provider.
  """

  alias __MODULE__, as: Comment
  alias Gullintanni.MergeRequest

  @type t ::
    %Comment{
      mreq_id: MergeRequest.id,
      sender: String.t,
      body: String.t,
      timestamp: NaiveDateTime.t
    }

  @enforce_keys [:mreq_id, :sender, :body, :timestamp]
  defstruct [:mreq_id, :sender, :body, :timestamp]

  @doc """
  Creates a new comment.
  """
  @spec new(MergeRequest.id, String.t, String.t, NaiveDateTime.t) :: t
  def new(mreq_id, sender, body, timestamp) do
    %Comment{
      mreq_id: mreq_id,
      sender: sender,
      body: body,
      timestamp: timestamp
    }
  end
end
