defmodule Day06 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_6_input.txt")

  def part_1 do
    @path
    |> parse_input()
    |> find_start(buffer_size: 4)
  end

  def part_2 do
    @path
    |> parse_input()
    |> find_start(buffer_size: 14)
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.graphemes()
  end

  defp find_start(chars, opts) do
    buffer_size = Keyword.fetch!(opts, :buffer_size)

    initial_buffer =
      chars
      |> Enum.take(buffer_size)
      |> Enum.reverse()

    rest = Enum.drop(chars, buffer_size)

    find_start(rest, initial_buffer, buffer_size)
  end

  defp find_start([h | t], buffer, count) do
    if start_found?(buffer) do
      count
    else
      find_start(t, [h | Enum.drop(buffer, -1)], count + 1)
    end
  end

  defp start_found?(buffer) do
    buffer == Enum.uniq(buffer)
  end
end
