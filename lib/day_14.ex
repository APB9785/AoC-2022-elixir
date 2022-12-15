defmodule Day14 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_14_input.txt")
  @entry_point {500, 0}

  # In order of priority
  @moves [{0, +1}, {-1, +1}, {+1, +1}]

  def part_1, do: total_sand_dropped(part: 1)

  def part_2, do: total_sand_dropped(part: 2)

  def total_sand_dropped(part: part) do
    @path
    |> parse_input()
    |> Map.put(:part, part)
    |> drop_sand()
    |> Map.fetch!(:sand)
    |> MapSet.size()
  end

  defp drop_sand(state) do
    if state.part == 2 and MapSet.member?(state.sand, @entry_point) do
      # This is the end condition for part 2
      state
    else
      new_sand = @entry_point
      do_move_sand(new_sand, state)
    end
  end

  # When we pass the bottom in part 1, it signals the end condition
  # When we pass the bottom in part 2, the sand is guaranteed to rest there
  defp do_move_sand({col, row}, %{bottom_row: bottom} = state) when row > bottom do
    case state do
      %{part: 1} -> state
      %{part: 2} -> rest_and_drop_new({col, row}, state)
    end
  end

  defp do_move_sand(current_coord, state) do
    possible_destinations = Enum.map(@moves, &destination(&1, current_coord))

    case Enum.find(possible_destinations, &unoccupied?(&1, state)) do
      nil -> rest_and_drop_new(current_coord, state)
      valid_destination -> do_move_sand(valid_destination, state)
    end
  end

  defp rest_and_drop_new(coord, state) do
    new_state = %{state | sand: MapSet.put(state.sand, coord)}
    drop_sand(new_state)
  end

  defp destination({x, y} = _move, {col, row} = _current) do
    {col + x, row + y}
  end

  defp unoccupied?(possibility, state) do
    !(MapSet.member?(state.sand, possibility) or MapSet.member?(state.rock, possibility))
  end

  def parse_input(path) do
    rock_coords =
      path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce(MapSet.new(), &parse_line/2)

    bottom_row =
      rock_coords
      |> Enum.map(fn {_col, row} -> row end)
      |> Enum.max()

    %{rock: rock_coords, sand: MapSet.new(), bottom_row: bottom_row}
  end

  defp parse_line(line_text, acc) do
    line_text
    |> String.split(" -> ")
    |> Enum.chunk_every(_count = 2, _step = 1, _leftover = :discard)
    |> Enum.reduce(acc, &parse_coords/2)
  end

  defp parse_coords([a, b], acc) do
    [a_col, a_row] = a |> String.split(",") |> Enum.map(&String.to_integer/1)
    [b_col, b_row] = b |> String.split(",") |> Enum.map(&String.to_integer/1)

    coords =
      case {b_col - a_col, b_row - a_row} do
        {0, _} -> for row <- a_row..b_row, do: {b_col, row}
        {_, 0} -> for col <- a_col..b_col, do: {col, b_row}
      end

    MapSet.union(acc, MapSet.new(coords))
  end
end
