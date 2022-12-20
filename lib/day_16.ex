defmodule Day16 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_16_input.txt")
  @init_state %{location: "AA", time: 0, water: 0, seen: MapSet.new()}
  @time_limit_pt_1 30
  @time_limit_pt_2 26

  def part_1, do: max_pressure_relief(part: 1)

  def part_2, do: max_pressure_relief(part: 2)

  def max_pressure_relief(part: part) do
    valve_info = parse_input(@path)
    digraph = graph_valves(valve_info)
    %{graph: primary_node_graph, rates: rates} = graph_primary(valve_info, digraph)

    seek(@init_state, primary_node_graph, rates, part: part)
  end

  defp seek(todo, graph, rates, part: 1) do
    case valid_next_steps(todo, graph, part: 1) do
      [] ->
        todo.water

      options ->
        seek_options(options, todo, graph, rates, &seek/4, part: 1)
    end
  end

  defp seek(todo, graph, rates, part: 2) do
    case valid_next_steps(todo, graph, part: 2) do
      [] ->
        init_elephant = %{location: "AA", time: 0, water: todo.water, seen: todo.seen}
        elephant_seek(init_elephant, graph, rates)

      options ->
        seek_options(options, todo, graph, rates, &seek/4, part: 2)
    end
  end

  defp elephant_seek(todo, graph, rates, _part \\ 2) do
    case valid_next_steps(todo, graph, part: 2) do
      [] ->
        todo.water

      options ->
        seek_options(options, todo, graph, rates, &elephant_seek/4, part: 2)
    end
  end

  defp seek_options(options, todo, graph, rates, seek_fn, part: part) do
    for destination <- options do
      time = todo.time + graph[todo.location][destination] + 1
      water = (time_limit(part: part) - time) * rates[destination] + todo.water
      seen = MapSet.put(todo.seen, destination)

      next_state = %{location: destination, time: time, water: water, seen: seen}

      seek_fn.(next_state, graph, rates, part: part)
    end
    |> Enum.max()
  end

  defp valid_next_steps(todo, graph, part: part) do
    graph
    |> Map.fetch!(todo.location)
    |> Map.filter(fn {_, v} -> time_limit(part: part) - todo.time - v > 0 end)
    |> Map.reject(fn {k, _} -> MapSet.member?(todo.seen, k) end)
    |> Map.keys()
  end

  defp time_limit(part: 1), do: @time_limit_pt_1
  defp time_limit(part: 2), do: @time_limit_pt_2

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line_text) do
    [a, b] = String.split(line_text, "; ")
    [_, valve, _, _, rate_text] = String.split(a, " ")
    [_, _, _, _, destinations_text] = String.split(b, " ", parts: 5)
    [_, rate] = String.split(rate_text, "=")
    destinations = String.split(destinations_text, ", ")

    %{valve: valve, destinations: destinations, rate: String.to_integer(rate)}
  end

  defp graph_valves(valves) do
    graph = :digraph.new()

    for %{valve: valve} <- valves do
      :digraph.add_vertex(graph, valve)
    end

    for %{destinations: destinations, valve: valve} <- valves,
        destination <- destinations do
      :digraph.add_edge(graph, valve, destination)
    end

    graph
  end

  defp graph_primary(valves, graph) do
    primary_valve_info = Enum.reject(valves, &(&1.rate == 0 and &1.valve != "AA"))

    rates = Map.new(primary_valve_info, &{&1.valve, &1.rate})

    graph =
      Enum.reduce(primary_valve_info, %{}, fn %{valve: name} = valve, acc ->
        other_valves = primary_valve_info -- [valve]

        destinations_map =
          Map.new(other_valves, fn %{valve: other_valve_name} ->
            [^name | path] = :digraph.get_short_path(graph, name, other_valve_name)
            {other_valve_name, length(path)}
          end)

        Map.put(acc, name, destinations_map)
      end)

    %{graph: graph, rates: rates}
  end
end
