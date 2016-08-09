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

  @typedoc "The value of an item"
  @type value :: any

  @typedoc "The priority of an item"
  @type priority :: integer

  @typedoc "A priority queue item"
  @type item :: {value, priority}

  @typedoc "The underlying data structure of a priority queue"
  @opaque data :: :gb_trees.tree

  @typedoc "The priority queue type"
  @type t :: %Queue{items: data, size: non_neg_integer}

  defstruct [items: :gb_trees.empty, size: 0]

  @default_priority 0

  @doc """
  Returns an empty priority queue.

  ## Examples

      iex> Gullintanni.Queue.new
      #Queue<empty>
  """
  @spec new :: t
  def new, do: new([])

  @doc """
  Creates a new priority queue from a list of enumerable `items`.

  Each item can be provided as a raw `value` (which will be inserted using the
  default priority of `#{@default_priority}`), or in the `{value, priority}`
  format.

  ## Examples

      iex> Gullintanni.Queue.new([:alice, :bob, :charlie])
      #Queue<size: 3, front: {:alice, 0}, rear: {:charlie, 0}>

      iex> Gullintanni.Queue.new([:alice, {:bob, 5}, :charlie])
      #Queue<size: 3, front: {:bob, 5}, rear: {:charlie, 0}>
  """
  @spec new(Enum.t) :: t
  def new(items) do
    Enum.reduce(items, %Queue{}, fn(item, queue) ->
      insert(queue, item)
    end)
  end

  @doc """
  Returns `true` if the `queue` is empty, otherwise `false`.

  ## Examples

      iex> queue = Gullintanni.Queue.new
      iex> Gullintanni.Queue.empty?(queue)
      true

      iex> queue = Gullintanni.Queue.new([:alice])
      iex> Gullintanni.Queue.empty?(queue)
      false
  """
  @spec empty?(t) :: boolean
  def empty?(%Queue{size: 0}), do: true
  def empty?(%Queue{}), do: false

  @doc """
  Inserts an `item` into the `queue`.

  The item can be provided as a raw `value` (which will be inserted using the
  default priority of `#{@default_priority}`), or in the `{value, priority}`
  format.

  Returns a new queue which is a copy of `queue` but with the item's value
  inserted at the specified priority. If there are existing values at the
  specified priority, the new value will have the lowest relative priority of
  those values.

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice])
      iex> Gullintanni.Queue.insert(queue, :bob)
      #Queue<size: 2, front: {:alice, 0}, rear: {:bob, 0}>

      iex> queue = Gullintanni.Queue.new([:alice])
      iex> Gullintanni.Queue.insert(queue, {:bob, 5})
      #Queue<size: 2, front: {:bob, 5}, rear: {:alice, 0}>
  """
  @spec insert(t, item | value) :: t
  def insert(queue, item)
  def insert(%Queue{} = queue, {value, priority}) when is_integer(priority) do
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
  def insert(%Queue{} = queue, value) do
    insert(queue, {value, @default_priority})
  end

  @doc """
  Deletes an `item` from the `queue`.

  Returns a new queue which is a copy of `queue` but without `item`. If the
  item did not exist previously, returns the queue unmodified. If the item's
  value occurs more than once at the specified priority, just the item with the
  highest relative priority is removed.

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.delete(queue, {:charlie, 0})
      #Queue<size: 2, front: {:alice, 0}, rear: {:bob, 0}>

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.delete(queue, {:dave, 0})
      #Queue<size: 3, front: {:alice, 0}, rear: {:charlie, 0}>

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie, :alice])
      iex> Gullintanni.Queue.delete(queue, {:alice, 0})
      #Queue<size: 3, front: {:bob, 0}, rear: {:alice, 0}>
  """
  @spec delete(t, item) :: t
  def delete(queue, item)
  def delete(%Queue{} = queue, {value, priority}) when is_integer(priority) do
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

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.move(queue, {:charlie, 0}, 5)
      #Queue<size: 3, front: {:charlie, 5}, rear: {:bob, 0}>

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.move(queue, {:dave, 0}, 5)
      #Queue<size: 3, front: {:alice, 0}, rear: {:charlie, 0}>

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie, :alice])
      iex> Gullintanni.Queue.move(queue, {:alice, 0}, 5)
      #Queue<size: 4, front: {:alice, 5}, rear: {:alice, 0}>
  """
  @spec move(t, item, priority) :: t
  def move(queue, item, new_priority)
  def move(%Queue{} = old_queue, {value, old_priority}, new_priority) do
    new_queue = delete(old_queue, {value, old_priority})

    if new_queue == old_queue do
      # no item was deleted
      old_queue
    else
      insert(new_queue, {value, new_priority})
    end
  end

  @doc """
  Returns the highest priority `item` in the `queue`.

  Returns `:empty` if the queue is empty.

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.peek(queue)
      {:alice, 0}

      iex> queue = Gullintanni.Queue.new
      iex> Gullintanni.Queue.peek(queue)
      :empty
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

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.peek_r(queue)
      {:charlie, 0}

      iex> queue = Gullintanni.Queue.new
      iex> Gullintanni.Queue.peek_r(queue)
      :empty
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

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> {new_queue, item} = Gullintanni.Queue.pop(queue)
      iex> new_queue
      #Queue<size: 2, front: {:bob, 0}, rear: {:charlie, 0}>
      iex> item
      {:alice, 0}

      iex> queue = Gullintanni.Queue.new
      iex> Gullintanni.Queue.pop(queue)
      :empty
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

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> {new_queue, item} = Gullintanni.Queue.pop_r(queue)
      iex> new_queue
      #Queue<size: 2, front: {:alice, 0}, rear: {:bob, 0}>
      iex> item
      {:charlie, 0}

      iex> queue = Gullintanni.Queue.new
      iex> Gullintanni.Queue.pop_r(queue)
      :empty
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

  ## Examples

      iex> queue = Gullintanni.Queue.new([:alice, :bob, :charlie])
      iex> Gullintanni.Queue.size(queue)
      3

      iex> queue = Gullintanni.Queue.new
      iex> Gullintanni.Queue.size(queue)
      0
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
          opts, fn(i, _opts) -> i end)
    end
  end
end