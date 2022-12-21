defmodule Day18 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_18_input.txt")

  def part_1 do
    coords = parse_input(@path)

    coords
    |> Enum.map(&sides_exposed(&1, coords))
    |> Enum.sum()
  end

  defp sides_exposed(coord, coords) do
    coord
    |> neighbors()
    |> Enum.count(&exposed?(&1, coords))
  end

  defp exposed?(coord, coords), do: !covered?(coord, coords)

  def part_2 do
    coords = parse_input(@path)
    {{min_x, _, _}, {max_x, _, _}} = Enum.min_max_by(coords, fn {x, _, _} -> x end)
    {{_, min_y, _}, {_, max_y, _}} = Enum.min_max_by(coords, fn {_, y, _} -> y end)
    {{_, _, min_z}, {_, _, max_z}} = Enum.min_max_by(coords, fn {_, _, z} -> z end)

    start = {max_x, max_y, max_z}

    init_state = %{
      todo: [start],
      bounds: %{
        x: %{min: min_x - 1, max: max_x + 1},
        y: %{min: min_y - 1, max: max_y + 1},
        z: %{min: min_z - 1, max: max_z + 1}
      },
      seen: %{
        coords: MapSet.new([start]),
        sides: MapSet.new()
      },
      coords: coords
    }

    init_state
    |> seek()
    |> Map.fetch!(:seen)
    |> Map.fetch!(:sides)
    |> MapSet.size()
  end

  defp seek(%{todo: []} = state), do: state

  defp seek(%{todo: [current_coord | rest]} = state) do
    current_coord
    |> neighbors()
    |> Enum.reduce(%{state | todo: rest}, fn neighbor, state ->
      cond do
        out_of_bounds?(neighbor, state) ->
          state

        already_seen?(neighbor, state) ->
          state

        covered?(neighbor, state.coords) ->
          new_seen_sides = MapSet.put(state.seen.sides, %{to: neighbor, from: current_coord})
          new_seen = %{state.seen | sides: new_seen_sides}
          %{state | seen: new_seen}

        :otherwise ->
          new_seen_coords = MapSet.put(state.seen.coords, neighbor)
          new_seen = %{state.seen | coords: new_seen_coords}
          %{state | seen: new_seen, todo: [neighbor | state.todo]}
      end
    end)
    |> seek()
  end

  defp neighbors({x, y, z}) do
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1}
    ]
  end

  defp out_of_bounds?({x, y, z}, %{bounds: bounds}) do
    x > bounds.x.max or x < bounds.x.min or
      y > bounds.y.max or y < bounds.y.min or
      z > bounds.z.max or z < bounds.z.min
  end

  defp already_seen?(coord, state), do: MapSet.member?(state.seen.coords, coord)

  defp covered?(coord, coords), do: MapSet.member?(coords, coord)

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> MapSet.new()
  end

  defp parse_line(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
