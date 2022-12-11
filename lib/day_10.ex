defmodule Day10 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_10_input.txt")
  @recorded_cycles [20, 60, 100, 140, 180, 220]
  @init_state %{cycle: 1, register_x: 1, signal_strengths: [], output: []}

  def part_1 do
    @path
    |> parse_input()
    |> Enum.reduce(@init_state, &run_cycle/2)
    |> Map.fetch!(:signal_strengths)
    |> Enum.sum()
  end

  def part_2 do
    @path
    |> parse_input()
    |> Enum.reduce(@init_state, &run_cycle/2)
    |> Map.fetch!(:output)
    |> Enum.reverse()
    |> Enum.chunk_every(40)
    |> Enum.intersperse(["\n"])
    |> IO.puts()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&parse_line/1)
  end

  defp parse_line("noop"), do: [:noop]

  defp parse_line(line) do
    ["addx", n] = String.split(line, " ")

    [:noop, {:add_x, String.to_integer(n)}]
  end

  defp run_cycle(:noop, state) do
    state
    |> maybe_record_signal_strength()
    |> record_output()
    |> Map.update!(:cycle, &(&1 + 1))
  end

  defp run_cycle({:add_x, n}, state) do
    state
    |> maybe_record_signal_strength()
    |> record_output()
    |> Map.update!(:register_x, &(&1 + n))
    |> Map.update!(:cycle, &(&1 + 1))
  end

  defp maybe_record_signal_strength(state) do
    if state.cycle in @recorded_cycles do
      %{state | signal_strengths: [state.register_x * state.cycle | state.signal_strengths]}
    else
      state
    end
  end

  defp record_output(state) do
    pixel =
      if row_position(state) in sprite(state),
        do: "#",
        else: "."

    %{state | output: [pixel | state.output]}
  end

  defp row_position(%{cycle: cycle}), do: rem(cycle - 1, 40)

  defp sprite(%{register_x: x}), do: [x - 1, x, x + 1]
end
