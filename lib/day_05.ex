defmodule Day05 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_5_input.txt")

  def part_1 do
    {stacks, instructions} = parse_input(@path)

    instructions
    |> Enum.reduce(stacks, &run_legacy_instruction/2)
    |> top_crates()
  end

  def part_2 do
    {stacks, instructions} = parse_input(@path)

    instructions
    |> Enum.reduce(stacks, &run_instruction/2)
    |> top_crates()
  end

  def parse_input(path) do
    [stacks, instructions] =
      path
      |> File.read!()
      |> String.split("\n\n")

    {parse_stacks(stacks), parse_instructions(instructions)}
  end

  defp parse_stacks(stacks) do
    stack_map = Map.new(1..9, &{&1, []})

    stacks
    |> String.split("\n")
    |> Enum.drop(-1)
    |> Enum.reduce(stack_map, &parse_stack_line/2)
    |> Map.new(fn {k, v} -> {k, Enum.reverse(v)} end)
  end

  defp parse_stack_line(line, map) do
    line
    |> String.graphemes()
    |> Enum.chunk_every(4)
    |> Enum.with_index(1)
    |> Enum.reduce(map, fn {chars, idx}, acc -> add_to_map(acc, chars, idx) end)
  end

  defp add_to_map(map, [" ", " ", " ", " "], _), do: map
  defp add_to_map(map, [" ", " ", " "], _), do: map

  defp add_to_map(map, ["[", letter, "]" | _], stack) do
    Map.update!(map, stack, &[letter | &1])
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction_line/1)
  end

  defp parse_instruction_line(line) do
    ["move", count, "from", source, "to", target] = String.split(line, " ")

    %{
      count: String.to_integer(count),
      source: String.to_integer(source),
      target: String.to_integer(target)
    }
  end

  defp run_legacy_instruction(%{count: 0}, stacks), do: stacks

  defp run_legacy_instruction(instruction, stacks) do
    %{source: source, target: target} = instruction
    [letter | rest] = stacks[source]

    updated_stacks =
      stacks
      |> Map.put(source, rest)
      |> Map.update!(target, &[letter | &1])

    instruction
    |> Map.update!(:count, &(&1 - 1))
    |> run_legacy_instruction(updated_stacks)
  end

  defp top_crates(stacks) do
    1..9
    |> Enum.map(&hd(stacks[&1]))
    |> Enum.join()
  end

  defp run_instruction(instruction, stacks) do
    %{count: count, source: source, target: target} = instruction

    letters = Enum.take(stacks[source], count)

    stacks
    |> Map.update!(source, &Enum.drop(&1, count))
    |> Map.update!(target, &(letters ++ &1))
  end
end
