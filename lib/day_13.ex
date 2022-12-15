defmodule Day13 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_13_input.txt")
  @divider_a [[2]]
  @divider_b [[6]]

  def part_1 do
    packets = parse_input(@path)

    packets
    |> Enum.chunk_every(2)
    |> Enum.with_index(_offset = 1)
    |> Enum.filter(&in_order?/1)
    |> Enum.map(fn {_pair, index} -> index end)
    |> Enum.sum()
  end

  def part_2 do
    packets = [@divider_a, @divider_b | parse_input(@path)]

    sorted_packets = Enum.sort(packets, __MODULE__)

    a_index = Enum.find_index(sorted_packets, &(&1 == @divider_a)) + 1
    b_index = Enum.find_index(sorted_packets, &(&1 == @divider_b)) + 1

    a_index * b_index
  end

  defp in_order?({[list_a, list_b] = _pair, _index}) do
    compare(list_a, list_b) == :lt
  end

  def compare([], _), do: :lt
  def compare(_, []), do: :gt
  def compare(a, b) when is_integer(a) and is_integer(b) and a < b, do: :lt
  def compare(a, b) when is_integer(a) and is_integer(b) and a > b, do: :gt
  def compare(a, b) when is_integer(a) and is_integer(b) and a == b, do: :eq
  def compare(a, b) when is_integer(a), do: compare([a], b)
  def compare(a, b) when is_integer(b), do: compare(a, [b])

  def compare([a | x], [b | y]) do
    case compare(a, b) do
      :eq -> compare(x, y)
      other -> other
    end
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
  end

  defp parse_packet(packet_text) do
    {packet, _} = Code.eval_string(packet_text)
    packet
  end
end
