defmodule Day07 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_7_input.txt")

  def part_1 do
    @path
    |> parse_input()
    |> map_file_system()
    |> list_directories_with_size()
    |> Map.reject(fn {_k, v} -> v > 100_000 end)
    |> Map.values()
    |> Enum.sum()
  end

  def part_2 do
    @path
    |> parse_input()
    |> map_file_system()
    |> list_directories_with_size()
    |> Enum.sort_by(fn {_dir, size} -> size end)
    |> find_proper_delete_size()
  end

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
  end

  defp map_file_system(commands) do
    commands
    |> Enum.reduce(%{pwd: []}, fn
      ["$", "cd", ".."], acc ->
        %{acc | pwd: Enum.drop(acc.pwd, -1)}

      ["$", "cd", relative_dir], acc ->
        new_pwd = acc.pwd ++ [relative_dir]

        acc
        |> put_in(new_pwd, %{})
        |> Map.put(:pwd, new_pwd)

      ["$", "ls"], acc ->
        acc

      ["dir", _], acc ->
        acc

      [size, name], acc ->
        put_in(acc, acc.pwd ++ [name], String.to_integer(size))
    end)
    |> Map.delete(:pwd)
  end

  defp list_directories_with_size(file_system) do
    file_system
    |> list_all_paths([])
    |> Enum.reduce(%{}, &calculate_size(&1, &2, file_system))
    |> Map.filter(fn {_path, {_size, type}} -> type == :folder end)
    |> Map.new(fn {k, {size, _type}} -> {k, size} end)
  end

  defp list_all_paths(n, _) when is_integer(n), do: []

  defp list_all_paths(file_system, path) do
    keys = Map.keys(file_system)

    Enum.flat_map(keys, fn key ->
      file_system
      |> Map.get(key)
      |> list_all_paths(path ++ [key])
    end) ++ Enum.map(keys, &(path ++ [&1]))
  end

  defp calculate_size(path, sizes, file_system) do
    case get_in(file_system, path) do
      value when is_integer(value) ->
        Map.put(sizes, path, {value, :file})

      values when is_map(values) ->
        total_size =
          values
          |> Map.keys()
          |> Enum.map(fn key ->
            {size, _type} = Map.get(sizes, path ++ [key])
            size
          end)
          |> Enum.sum()

        Map.put(sizes, path, {total_size, :folder})
    end
  end

  defp find_proper_delete_size(directories_sorted_by_size) do
    [{["/"], total_used}] = Enum.take(directories_sorted_by_size, -1)
    free_space = 70_000_000 - total_used

    directories_sorted_by_size
    |> Enum.find(fn {_k, v} -> v + free_space >= 30_000_000 end)
    |> elem(1)
  end
end
