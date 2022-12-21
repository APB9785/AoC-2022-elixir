defmodule Day17 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_17_input.txt")

  @piece_set [
    _horizontal_line = [{3, 0}, {4, 0}, {5, 0}, {6, 0}],
    _plus = [{4, 2}, {3, 1}, {4, 1}, {4, 0}, {5, 1}],
    _corner = [{5, 2}, {3, 0}, {4, 0}, {5, 0}, {5, 1}],
    _vertical_line = [{3, 3}, {3, 0}, {3, 1}, {3, 2}],
    _square = [{3, 1}, {3, 0}, {4, 0}, {4, 1}]
  ]

  @trillion 1_000_000_000_000

  def parse_input(path) do
    path
    |> File.read!()
    |> String.graphemes()
    |> Enum.drop(_index = -1)
    |> Enum.map(fn
      ">" -> +1
      "<" -> -1
    end)
  end

  def part_1 do
    pushes = parse_input(@path)
    init_state = %{rows: %{}, top: 0, pushes: pushes, backup_pushes: pushes}

    @piece_set
    |> Stream.cycle()
    |> Enum.take(2022)
    |> Enum.reduce(init_state, &simulate_piece/2)
    |> Map.fetch!(:top)
  end

  def part_2 do
    pushes = parse_input(@path)

    init_state = %{
      rows: %{0 => [1, 2, 3, 4, 5, 6, 7]},
      top: 0,
      pushes: pushes,
      backup_pushes: pushes,
      snapshots: %{}
    }

    # First run the simulation until a cycle is found
    {cycle_start, cycle_end, top_gain, after_state, next_piece} = find_cycle(init_state)

    # This will start us with the same piece queued at the end of the cycles
    piece_offset = Enum.find_index(@piece_set, &(&1 == next_piece))

    # Calculate how many cycles there are before we reach 1-trillion
    cycle_size = cycle_end - cycle_start
    left_todo = @trillion - cycle_end + 1
    cycles = div(left_todo, cycle_size)

    top_gain_during_cycles = top_gain * cycles
    pieces_dropped_during_cycles = cycles * cycle_size

    # With this data we can instantly calculate what the state looks like
    # after all cycles are complete
    todo_after_cycles = left_todo - pieces_dropped_during_cycles
    top_after_cycles = after_state.top + top_gain_during_cycles

    rows_after_cycles =
      Map.new(after_state.rows, fn {row, occupied} ->
        {row + top_gain_during_cycles, occupied}
      end)

    # Next we need to simulate the leftover pieces which bring us to the goal of 1-trillion
    @piece_set
    |> Stream.cycle()
    |> Stream.drop(piece_offset)
    |> Stream.take(todo_after_cycles)
    |> Enum.reduce(
      %{after_state | top: top_after_cycles, rows: rows_after_cycles},
      &simulate_piece/2
    )
    |> Map.fetch!(:top)
  end

  defp simulate_piece(piece, state) do
    piece
    |> spawn_new(state.top)
    |> move_until_blocked(state)
  end

  defp spawn_new(piece, top) do
    Enum.map(piece, fn {x, y} -> {x, y + top + 4} end)
  end

  defp move_until_blocked(piece, %{pushes: []} = state),
    do: move_until_blocked(piece, %{state | pushes: state.backup_pushes})

  defp move_until_blocked(piece, %{rows: rows, pushes: [x_vector | rest], top: top} = state) do
    # Horizontal move from push
    {_, piece} = attempt_move(piece, {x_vector, 0}, rows)

    # Vertical drop
    case attempt_move(piece, {0, -1}, rows) do
      {:blocked, ^piece} ->
        [{_, piece_top} | _] = piece
        new_top = Enum.max([piece_top, top])

        new_rows =
          rows
          |> add_coords(piece)
          |> trim_rows(new_top)

        %{state | rows: new_rows, top: new_top, pushes: rest}

      {:moved, moved_piece} ->
        move_until_blocked(moved_piece, %{state | pushes: rest})
    end
  end

  defp attempt_move(piece, {dx, dy}, rows) do
    new_coords = Enum.map(piece, fn {x, y} -> {x + dx, y + dy} end)

    if Enum.any?(new_coords, &blocked?(&1, rows)) do
      {:blocked, piece}
    else
      {:moved, new_coords}
    end
  end

  defp blocked?({x, y}, _) when x < 1 or x > 7 or y < 1, do: true

  defp blocked?({x, y}, rows) do
    case rows[y] do
      nil -> false
      row -> x in row
    end
  end

  defp add_coords(rows, piece) do
    Enum.reduce(piece, rows, fn {x, y}, acc ->
      Map.update(acc, y, [x], &[x | &1])
    end)
  end

  defp trim_rows(rows, top) do
    Map.reject(rows, fn {row, _} -> top - row > 50 end)
  end

  defp find_cycle(init_state) do
    @piece_set
    |> Stream.cycle()
    |> Stream.with_index(_offset = 1)
    |> Enum.reduce_while(init_state, fn {piece, piece_number}, acc ->
      snapshot = {piece, acc.pushes, floor_offsets(acc.rows)}

      case Map.get(acc.snapshots, snapshot) do
        nil ->
          new_acc = %{acc | snapshots: Map.put(acc.snapshots, snapshot, {piece_number, acc.top})}
          {:cont, simulate_piece(piece, new_acc)}

        {last_seen, old_top} ->
          {:halt, {last_seen, piece_number, acc.top - old_top, acc, piece}}
      end
    end)
  end

  defp floor_offsets(rows) do
    tops =
      rows
      |> Enum.sort(:desc)
      |> get_tops()

    floor =
      tops
      |> Map.values()
      |> Enum.min()

    Map.new(tops, fn {col, row} -> {col, row - floor} end)
  end

  defp get_tops(sorted_rows) do
    Enum.reduce_while(sorted_rows, %{}, fn {row, occupied}, acc ->
      new_acc = Enum.reduce(occupied, acc, &Map.put_new(&2, &1, row))

      if map_size(new_acc) == 7 do
        {:halt, new_acc}
      else
        {:cont, new_acc}
      end
    end)
  end
end
