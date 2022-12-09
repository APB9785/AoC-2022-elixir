defmodule Day09 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_9_input.txt")
  @directions %{"U" => :north, "D" => :south, "L" => :west, "R" => :east}
  @unit_vectors %{north: {0, 1}, south: {0, -1}, west: {-1, 0}, east: {1, 0}}
  @origin {0, 0}

  def part_1 do
    state = %{
      head: @origin,
      tail: @origin,
      motions: parse_input(@path),
      seen_by_tail: MapSet.new([@origin]),
      knots: [:head, :tail]
    }

    state
    |> run_motions()
    |> Map.fetch!(:seen_by_tail)
    |> MapSet.size()
  end

  def part_2 do
    state = %{
      motions: parse_input(@path),
      seen_by_tail: MapSet.new([@origin]),
      knots: [:head, :one, :two, :three, :four, :five, :six, :seven, :eight, :tail]
    }

    state = Enum.reduce(state.knots, state, &Map.put(&2, &1, @origin))

    state
    |> run_motions()
    |> Map.fetch!(:seen_by_tail)
    |> MapSet.size()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [letter, number] = String.split(line, " ")
    {@directions[letter], String.to_integer(number)}
  end

  defp run_motions(%{motions: []} = state), do: state

  defp run_motions(state) do
    [todo | rest] = state.motions
    {direction, steps} = todo

    state = %{state | motions: rest}
    state = Enum.reduce(1..steps, state, fn _, acc -> move_rope(acc, direction) end)

    run_motions(state)
  end

  defp move_rope(state, direction) do
    state = move_head(state, direction)
    knot_pairs = Enum.chunk_every(state.knots, 2, 1, :discard)

    state = Enum.reduce(knot_pairs, state, &move_tail/2)

    %{state | seen_by_tail: MapSet.put(state.seen_by_tail, state.tail)}
  end

  defp move_head(state, direction) do
    {x, y} = state.head
    {vx, vy} = @unit_vectors[direction]

    %{state | head: {x + vx, y + vy}}
  end

  defp move_tail([head_key, tail_key], state) do
    {head_x, head_y} = state[head_key]
    {tail_x, tail_y} = state[tail_key]
    {dx, dy} = {tail_x - head_x, tail_y - head_y}

    vx = compare(dx, dy)
    vy = compare(dy, dx)

    Map.put(state, tail_key, {tail_x + vx, tail_y + vy})
  end

  defp compare(a, b) do
    case a do
      0 -> 0
      -1 when b > 1 or b < -1 -> 1
      -2 -> 1
      1 when b > 1 or b < -1 -> -1
      2 -> -1
      _ -> 0
    end
  end
end
