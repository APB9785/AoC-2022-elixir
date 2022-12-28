defmodule Day21 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_21_input.txt")

  def part_1 do
    monkeys = parse_input(@path)
    get_value("root", monkeys)
  end

  def part_2 do
    monkeys = parse_input(@path)
    find_equal(monkeys)
  end

  defp find_equal(min \\ 0, max \\ 999_999_999_999_999, monkeys) do
    {a, _, b} = Map.fetch!(monkeys, "root")
    n = min + div(max - min, 2)

    new_monkeys = replace_humn(n, monkeys)
    va = get_value(a, new_monkeys)
    vb = get_value(b, new_monkeys)

    cond do
      va > vb -> find_equal(n, max, new_monkeys)
      va < vb -> find_equal(min, n, new_monkeys)
      va == vb -> n - 1
    end
  end

  defp get_value(monkey_name, monkeys) do
    case Map.fetch!(monkeys, monkey_name) do
      {a, op, b} -> op.(get_value(a, monkeys), get_value(b, monkeys))
      n -> n
    end
  end

  defp replace_humn(n, monkeys) do
    Map.put(monkeys, "humn", n)
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Map.new(&parse_line/1)
  end

  defp parse_line(line) do
    [monkey, job] = String.split(line, ": ")

    parsed =
      case String.split(job, " ") do
        [a, op, b] -> {a, parse_op(op), b}
        [n] -> String.to_integer(n)
      end

    {monkey, parsed}
  end

  defp parse_op("-"), do: &Kernel.-/2
  defp parse_op("+"), do: &Kernel.+/2
  defp parse_op("*"), do: &Kernel.*/2
  defp parse_op("/"), do: &Kernel.div/2
end
