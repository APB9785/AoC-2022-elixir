defmodule Day08 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_8_input.txt")

  @unit_vectors %{north: {0, -1}, east: {1, 0}, south: {0, 1}, west: {-1, 0}}
  @directions Map.keys(@unit_vectors)

  def part_1 do
    tree_height_map = parse_input(@path)

    Enum.count(tree_height_map, fn {coord, _height} ->
      !blocked?(coord, tree_height_map)
    end)
  end

  def part_2 do
    tree_height_map = parse_input(@path)
    coords = Map.keys(tree_height_map)
    max_row = coords |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_col = coords |> Enum.map(&elem(&1, 0)) |> Enum.max()

    coords
    |> Enum.map(&scenic_score(&1, tree_height_map, {max_col, max_row}))
    |> Enum.max()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, &map_row/2)
  end

  defp map_row({text, row_number}, tree_height_map) do
    trees =
      text
      |> String.graphemes()
      |> Enum.with_index()

    Enum.reduce(trees, tree_height_map, fn {height, col_number}, acc ->
      height = String.to_integer(height)
      Map.put(acc, {col_number, row_number}, height)
    end)
  end

  defp blocked?(coord, tree_height_map) do
    base_height = tree_height_map[coord]

    cond do
      traverse(coord, :north, tree_height_map, base_height) == :not_blocked -> false
      traverse(coord, :east, tree_height_map, base_height) == :not_blocked -> false
      traverse(coord, :south, tree_height_map, base_height) == :not_blocked -> false
      traverse(coord, :west, tree_height_map, base_height) == :not_blocked -> false
      :otherwise -> true
    end
  end

  defp scenic_score(coord, tree_height_map, grid_bounds) do
    base_height = tree_height_map[coord]

    @directions
    |> Enum.map(fn direction ->
      case traverse(coord, direction, tree_height_map, base_height) do
        :not_blocked -> distance_from_edge(coord, direction, grid_bounds)
        {:blocked_at, blocked_coord} -> distance_between(coord, blocked_coord)
      end
    end)
    |> Enum.product()
  end

  defp traverse({col, row}, direction, tree_height_map, base_height) do
    {vx, vy} = @unit_vectors[direction]
    new_coord = {col + vx, row + vy}

    case tree_height_map[new_coord] do
      nil -> :not_blocked
      height when height >= base_height -> {:blocked_at, new_coord}
      _height -> traverse(new_coord, direction, tree_height_map, base_height)
    end
  end

  defp distance_from_edge({x, y}, direction, {max_col, max_row}) do
    edge_coord =
      case direction do
        :north -> {x, 0}
        :south -> {x, max_row}
        :east -> {max_col, y}
        :west -> {0, y}
      end

    distance_between({x, y}, edge_coord)
  end

  defp distance_between({x, y1}, {x, y2}), do: abs(y2 - y1)
  defp distance_between({x1, y}, {x2, y}), do: abs(x2 - x1)
end
