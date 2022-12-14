defmodule Day11 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_11_input.txt")

  def part_1 do
    state = parse_input(@path)
    state = Enum.reduce(1..20, state, fn _, acc -> simulate_round(acc, &div(&1, 3)) end)

    monkey_business(state)
  end

  def part_2 do
    state = parse_input(@path)
    lcm = state.keys |> Enum.map(&state[&1][:test_divisor]) |> lcm()
    state = Enum.reduce(1..10_000, state, fn _, acc -> simulate_round(acc, &rem(&1, lcm)) end)

    monkey_business(state)
  end

  defp simulate_round(state, relief_fn) do
    Enum.reduce(state.keys, state, fn monkey_id, acc ->
      monkey = acc[monkey_id]

      items =
        monkey.items
        |> Enum.map(monkey.operation)
        |> Enum.map(relief_fn)

      {pass, fail} = Enum.split_with(items, &(rem(&1, monkey.test_divisor) == 0))

      monkey_with_passes =
        acc
        |> Map.fetch!(monkey.throw_when_true)
        |> Map.update!(:items, &(pass ++ &1))

      monkey_with_fails =
        acc
        |> Map.fetch!(monkey.throw_when_false)
        |> Map.update!(:items, &(fail ++ &1))

      primary_monkey =
        monkey
        |> Map.put(:items, [])
        |> Map.update!(:inspects, &(&1 + length(items)))

      acc
      |> Map.put(primary_monkey.id, primary_monkey)
      |> Map.put(monkey_with_passes.id, monkey_with_passes)
      |> Map.put(monkey_with_fails.id, monkey_with_fails)
    end)
  end

  defp monkey_business(state) do
    state
    |> Map.delete(:keys)
    |> Enum.map(fn {_id, monkey} -> monkey.inspects end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(&parse_monkey/1)
    |> Map.new(fn monkey -> {monkey.id, monkey} end)
    |> then(&Map.put(&1, :keys, Map.keys(&1)))
  end

  defp parse_monkey(monkey_text) do
    monkey_text
    |> String.split("\n", trim: true)
    |> Map.new(&parse_line/1)
    |> Map.put(:inspects, 0)
  end

  defp parse_line("Monkey " <> rest) do
    {:id,
     rest
     |> String.replace(":", "")
     |> String.to_integer()}
  end

  defp parse_line("  Starting items: " <> rest) do
    {:items,
     rest
     |> String.split(", ")
     |> Enum.map(&String.to_integer/1)}
  end

  defp parse_line("  Operation: new = " <> rest) do
    [a, op, b] = String.split(rest, " ")
    op = parse_op(op)
    [a, b] = Enum.map([a, b], &parse_arg/1)

    {:operation,
     fn old ->
       x = if a == :old, do: old, else: a
       y = if b == :old, do: old, else: b
       op.(x, y)
     end}
  end

  defp parse_line("  Test: divisible by " <> rest) do
    {:test_divisor, String.to_integer(rest)}
  end

  defp parse_line("    If true: throw to monkey " <> rest) do
    {:throw_when_true, String.to_integer(rest)}
  end

  defp parse_line("    If false: throw to monkey " <> rest) do
    {:throw_when_false, String.to_integer(rest)}
  end

  defp parse_arg("old"), do: :old
  defp parse_arg(n), do: String.to_integer(n)

  defp parse_op("+"), do: &Kernel.+/2
  defp parse_op("*"), do: &Kernel.*/2

  defp lcm(list), do: Enum.reduce(list, &lcm/2)
  defp lcm(0, 0), do: 0
  defp lcm(a, b), do: div(a * b, gcd(a, b))

  defp gcd(a, 0), do: a
  defp gcd(0, b), do: b
  defp gcd(a, b), do: gcd(b, rem(a, b))
end
