defmodule Day03 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_3_input.txt")

  def part_1 do
    @path
    |> parse_input()
    |> Enum.map(&bisect_line/1)
    |> Enum.map(&priority_of_shared_item/1)
    |> Enum.sum()
  end

  def part_2 do
    @path
    |> parse_input()
    |> Enum.chunk_every(3)
    |> Enum.map(&priority_of_shared_item/1)
    |> Enum.sum()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp bisect_line(line) do
    midpoint =
      line
      |> String.length()
      |> div(2)

    String.split_at(line, midpoint)
  end

  defp priority_of_shared_item({a, b}) do
    a
    |> compare(b)
    |> priority()
  end

  defp priority_of_shared_item([a, b, c]) do
    a
    |> compare(b)
    |> compare(c)
    |> priority()
  end

  defp compare(a, b) do
    [set_a, set_b] = Enum.map([a, b], &set_from_string/1)

    set_a
    |> MapSet.intersection(set_b)
    |> MapSet.to_list()
    |> List.to_string()
  end

  defp set_from_string(string) do
    string
    |> String.graphemes()
    |> MapSet.new()
  end

  defp priority(letter) do
    case String.to_charlist(letter) do
      [number] when number >= 97 and number <= 122 ->
        number - 96

      [number] when number >= 65 and number <= 90 ->
        number - 38
    end
  end
end
