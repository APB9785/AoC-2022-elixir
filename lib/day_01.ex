defmodule Day01 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_1_input.txt")

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n\n")
  end

  def part_1 do
    @path
    |> parse_input()
    |> Enum.map(&count_inventory/1)
    |> Enum.max()
  end

  def part_2 do
    @path
    |> parse_input()
    |> Enum.map(&count_inventory/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp count_inventory(inv) do
    inv
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end
