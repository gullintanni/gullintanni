defmodule Gullintanni.Queue do
  @moduledoc """
  Provides priority queues in a relatively efficient manner.

  Queues are double-ended. The mental picture of a queue is a line of people
  (items) waiting for their turn. The queue *front* is the end with the item
  that has waited the longest. The queue *rear* is the end an item enters when
  it starts to wait. If instead using the mental picture of a list, the front
  is called head and the rear is called tail. A priority queue adds the idea
  that an item can skip ahead in line according to its importance (priority).

  Each item in a priority queue is represented as a tuple with both its *value*
  and *priority*. Priorities must be integers, with higher integers being
  treated as higher in priority. Multiple items may exist with the same
  priority and are used in First-In First-Out (FIFO) order.

  The data representing a priority queue as used by this module is to be
  regarded as opaque by other modules.
  """

  alias __MODULE__, as: Queue

  @type value :: any
  @type priority :: integer
  @type item :: {value, priority}
  @opaque data :: :gb_trees.tree
  @type t :: %Queue{items: data, size: non_neg_integer}

  defstruct [:items, :size]

  @doc """
  Creates a new empty priority queue.
  """
  # FIXME: dialyzer throws a badarg error if the return type is `t`
  @spec new :: struct
  def new, do: %Queue{items: :gb_trees.empty, size: 0}

  @doc """
  Returns `true` if the `queue` is empty, otherwise `false`.
  """
  @spec empty?(t) :: boolean
  def empty?(%Queue{size: 0}), do: true
  def empty?(%Queue{}), do: false

  @doc """
  Inserts an `item` into the `queue`.

  Returns a new queue which is a copy of `queue` but with the item's value
  inserted at the specified priority. If there are existing values at the
  specified priority, the new value will have the lowest relative priority of
  those values.
  """
  @spec insert(t, item) :: t
  def insert(%Queue{} = queue, {value, priority} = _item) when is_integer(priority) do
    values =
      case :gb_trees.lookup(priority, queue.items) do
        :none -> [value]
        {:value, rest} -> [value|rest]
      end

    %{queue |
      :items => :gb_trees.enter(priority, values, queue.items),
      :size => queue.size + 1
    }
  end

  @doc """
  Deletes an `item` from the `queue`.

  Returns a new queue which is a copy of `queue` but without `item`. If the
  item did not exist previously, returns the queue unmodified. If the item's
  value occurs more than once at the specified priority, just the item with the
  highest relative priority is removed.
  """
  @spec delete(t, item) :: t
  def delete(%Queue{} = queue, {value, priority} = _item) when is_integer(priority) do
    case :gb_trees.lookup(priority, queue.items) do
      :none ->
        queue
      {:value, [^value]} ->
        %{queue |
           :items => :gb_trees.delete(priority, queue.items),
           :size => queue.size - 1
        }
      {:value, old_values} ->
        new_values =
          old_values
          |> Enum.reverse
          |> List.delete(value)
          |> Enum.reverse

        if new_values == old_values do
          # no item was deleted
          queue
        else
          %{queue |
            :items => :gb_trees.update(priority, new_values, queue.items),
            :size => queue.size - 1
          }
        end
    end
  end

  @doc """
  Moves an `item` to a different priority in the `queue`.

  Returns a new queue which is a copy of `queue` but with the item's value
  moved to the specified priority. If the item did not exist previously,
  returns the queue unmodified. If the item's value occurs more than once at
  the specified priority, just the item with the highest relative priority is
  moved.
  """
  @spec move(t, item, priority) :: t
  def move(%Queue{} = queue, {value, old_priority} = _item, new_priority) do
    new_queue = delete(queue, {value, old_priority})

    if new_queue == queue do
      # no item was deleted
      queue
    else
      insert(new_queue, {value, new_priority})
    end
  end

  @doc """
  Returns the highest priority `item` in the `queue`.

  Returns `:empty` if the queue is empty.
  """
  @spec peek(t) :: item | :empty
  def peek(%Queue{size: 0}), do: :empty
  def peek(%Queue{} = queue) do
    {priority, values, _queue} = :gb_trees.take_largest(queue.items)
    {List.last(values), priority}
  end

  @doc """
  Returns the lowest priority `item` in the `queue`.

  Returns `:empty` if the queue is empty.
  """
  @spec peek_r(t) :: item | :empty
  def peek_r(%Queue{size: 0}), do: :empty
  def peek_r(%Queue{} = queue) do
    {priority, values, _queue} = :gb_trees.take_smallest(queue.items)
    {List.first(values), priority}
  end

  @doc """
  Returns and removes the highest priority `item` in the `queue`.

  Returns `:empty` if the queue is empty.
  """
  @spec pop(t) :: {t, item} | :empty
  def pop(%Queue{size: 0}), do: :empty
  def pop(%Queue{} = queue) do
    item = peek(queue)
    new_queue = delete(queue, item)
    {new_queue, item}
  end

  @doc """
  Returns and removes the lowest priority `item` in the `queue`.

  Returns `:empty` if the queue is empty.
  """
  @spec pop_r(t) :: {t, item} | :empty
  def pop_r(%Queue{size: 0}), do: :empty
  def pop_r(%Queue{} = queue) do
    item = peek_r(queue)
    new_queue = delete(queue, item)
    {new_queue, item}
  end

  @doc """
  Returns the number of items in the `queue`.
  """
  @spec size(t) :: non_neg_integer
  def size(%Queue{} = queue), do: queue.size
end


defimpl Enumerable, for: Gullintanni.Queue do
  @empty :gb_trees.empty

  # force use of the default algorithm
  def count(_queue) do
    {:error, __MODULE__}
  end

  def member?(queue, {value, priority}) do
    case :gb_trees.lookup(priority, queue.items) do
      :none ->
        {:ok, false}
      {:value, values} ->
        case Enum.find(values, &(&1 == value)) do
          nil -> {:ok, false}
          _ -> {:ok, true}
        end
    end
  end

  def reduce(_, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(queue, {:suspend, acc}, fun) do
    {:suspended, acc, &reduce(queue, &1, fun)}
  end
  def reduce(%Gullintanni.Queue{items: @empty}, {:cont, acc}, _fun) do
    {:done, acc}
  end
  def reduce(queue, {:cont, acc}, fun) do
    {rest, item} = Gullintanni.Queue.pop(queue)
    reduce(rest, fun.(item, acc), fun)
  end
end


defimpl Inspect, for: Gullintanni.Queue do
  import Inspect.Algebra

  def inspect(queue, opts) do
    case queue.size do
      0 -> "#Queue<empty>"
      _ ->
        size = "size: #{queue.size}"
        front = "front: #{inspect Gullintanni.Queue.peek(queue)}"
        rear = "rear: #{inspect Gullintanni.Queue.peek_r(queue)}"

        surround_many("#Queue<", [size, front, rear], ">",
          opts, fn i, _opts -> i end)
    end
  end
end
