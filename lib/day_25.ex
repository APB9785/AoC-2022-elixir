defmodule Day25 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_25_input.txt")

  def part_1 do
    @path
    |> parse_input()
    |> Enum.map(&snafu_to_int/1)
    |> Enum.sum()
    |> int_to_snafu()
  end

  def part_2, do: nil

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def snafu_to_int(line) do
    places_stream = Stream.iterate(1, &(&1 * 5))

    line
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.map(&parse_integer/1)
    |> Enum.zip(places_stream)
    |> Enum.map(fn {n, place} -> n * place end)
    |> Enum.sum()
  end

  defp parse_integer(i) when i in ~w(0 1 2), do: String.to_integer(i)
  defp parse_integer("-"), do: -1
  defp parse_integer("="), do: -2

  def int_to_snafu(n) do
    n
    |> Integer.to_string(5)
    |> String.graphemes()
    |> Enum.reverse()
    |> do_carryover([])
    |> Enum.join()
  end

  defp do_carryover([last], done) when last in ~w(0 1 2), do: [last | done]

  defp do_carryover(["3", next | rest], done),
    do: do_carryover([increment(next) | rest], ["=" | done])

  defp do_carryover(["4", next | rest], done),
    do: do_carryover([increment(next) | rest], ["-" | done])

  defp do_carryover([valid, next | rest], done) when valid in ~w(0 1 2),
    do: do_carryover([next | rest], [valid | done])

  defp increment("="), do: "-"
  defp increment("-"), do: "0"
  defp increment("0"), do: "1"
  defp increment("1"), do: "2"
  defp increment("2"), do: "3"
  defp increment("3"), do: "4"
end
