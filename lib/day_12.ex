defmodule Day12 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_12_input.txt")
  @unit_vectors [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def part_1 do
    %{part_1_start: start, destination: destination, graph: graph} = parse_input(@path)

    graph
    |> best_path_length(start, destination)
    |> tap(fn _ -> :digraph.delete(graph) end)
  end

  def part_2 do
    %{part_2_possible_starts: starts, destination: destination, graph: graph} = parse_input(@path)

    starts
    |> Enum.map(&best_path_length(graph, &1, destination))
    |> Enum.min()
    |> tap(fn _ -> :digraph.delete(graph) end)
  end

  def parse_input(path) do
    {endpoints, height_map} =
      path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, &parse_line/2)
      |> Map.split([:start, :destination])

    part_2_possible_starts =
      height_map
      |> Map.filter(fn {_k, v} -> v == 1 end)
      |> Map.keys()

    %{
      graph: create_digraph(height_map),
      part_1_start: endpoints.start,
      part_2_possible_starts: part_2_possible_starts,
      destination: endpoints.destination
    }
  end

  defp create_digraph(height_map) do
    graph = :digraph.new()

    for {coord, _height} <- height_map do
      :digraph.add_vertex(graph, coord)
    end

    for {coord, _height} <- height_map,
        neighbor <- valid_neighbors(coord, height_map) do
      :digraph.add_edge(graph, coord, neighbor)
    end

    graph
  end

  defp parse_line({line_text, row}, acc) do
    line_text
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(acc, &map_coord(&1, &2, row))
  end

  defp map_coord({"E", col}, acc, row) do
    acc
    |> Map.put({row, col}, 26)
    |> Map.put(:destination, {row, col})
  end

  defp map_coord({"S", col}, acc, row) do
    acc
    |> Map.put({row, col}, 1)
    |> Map.put(:start, {row, col})
  end

  defp map_coord({char, col}, acc, row) do
    [n] = String.to_charlist(char)
    height = n - 96

    Map.put(acc, {row, col}, height)
  end

  defp valid_neighbors({row, col} = coord, height_map) do
    current_height = height_map[coord]
    neighbors = Enum.map(@unit_vectors, fn {x, y} -> {row + y, col + x} end)

    Enum.filter(neighbors, fn neighbor ->
      case height_map[neighbor] do
        nil -> nil
        neighbor_height -> neighbor_height <= current_height + 1
      end
    end)
  end

  defp best_path_length(graph, start, destination) do
    case :digraph.get_short_path(graph, start, destination) do
      false -> :infinity
      [^start | path] -> length(path)
    end
  end
end
