defmodule Day04 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_4_input.txt")

  def part_1 do
    @path
    |> parse_input()
    |> Enum.count(&full_overlap?/1)
  end

  def part_2 do
    @path
    |> parse_input()
    |> Enum.count(&partial_overlap?/1)
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(",")
    |> Enum.map(&string_to_range/1)
    |> List.to_tuple()
  end

  defp string_to_range(string) do
    [a, b] =
      string
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    a..b
  end

  defp full_overlap?({range_1, range_2}) do
    Enum.all?(range_1, &(&1 in range_2)) or
      Enum.all?(range_2, &(&1 in range_1))
  end

  defp partial_overlap?({range_1, range_2}) do
    Enum.any?(range_1, &(&1 in range_2)) or
      Enum.any?(range_2, &(&1 in range_1))
  end
end
