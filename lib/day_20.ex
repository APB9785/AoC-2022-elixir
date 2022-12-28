defmodule Day20 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_20_input.txt")
  @decryption_key 811_589_153

  def part_1 do
    # First swap out the numbers for (1-based) indexes, so we can guarantee unique list items
    # We will convert back to real values at the end during scoring
    lookup =
      @path
      |> parse_input()
      |> Enum.with_index(_offset = 1)
      |> Map.new(fn {n, idx} -> {idx, n} end)

    values = Enum.to_list(1..map_size(lookup))

    values
    |> Enum.reduce(values, &move_number(&1, &2, lookup))
    |> score(lookup)
  end

  def part_2 do
    lookup =
      @path
      |> parse_input()
      |> Enum.with_index(_offset = 1)
      |> Map.new(fn {n, idx} -> {idx, n * @decryption_key} end)

    values = Enum.to_list(1..map_size(lookup))

    1..10
    |> Enum.reduce(values, fn _, acc ->
      Enum.reduce(values, acc, &move_number(&1, &2, lookup))
    end)
    |> score(lookup)
  end

  defp move_number(number, list, lookup) do
    # This index is zero-based and used only for popping/re-inserting the number
    idx = Enum.find_index(list, &(&1 == number))
    {^number, list_without_number} = List.pop_at(list, idx)
    new_idx = find_new_index(number, idx, lookup)

    List.insert_at(list_without_number, new_idx, number)
  end

  defp find_new_index(number, index, lookup) do
    value = Map.fetch!(lookup, number)
    raw_idx = index + value
    mod = map_size(lookup) - 1

    Integer.mod(raw_idx, mod)
  end

  defp score(list, lookup) do
    score_list = Enum.map(list, &Map.fetch!(lookup, &1))
    zero_idx = Enum.find_index(score_list, &(&1 == 0))
    mod = map_size(lookup) - 1

    [1000, 2000, 3000]
    |> Enum.map(&Enum.at(score_list, Integer.mod(zero_idx + &1, mod)))
    |> Enum.sum()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
