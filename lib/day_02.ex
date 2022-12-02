defmodule Day02 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_2_input.txt")

  def part_1 do
    @path
    |> parse_input(:part_1)
    |> Enum.map(&score_round/1)
    |> Enum.sum()
  end

  def part_2 do
    @path
    |> parse_input(:part_2)
    |> Enum.map(&insert_self_choice/1)
    |> Enum.map(&score_round/1)
    |> Enum.sum()
  end

  def parse_input(path, strategy) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line(&1, strategy))
  end

  defp parse_line(line, strategy) do
    line
    |> String.split(" ")
    |> Enum.map(&parse_letter(&1, strategy))
    |> List.to_tuple()
  end

  defp parse_letter("A", _), do: :rock
  defp parse_letter("B", _), do: :paper
  defp parse_letter("C", _), do: :scissors
  defp parse_letter("X", :part_1), do: :rock
  defp parse_letter("Y", :part_1), do: :paper
  defp parse_letter("Z", :part_1), do: :scissors
  defp parse_letter("X", :part_2), do: :loss
  defp parse_letter("Y", :part_2), do: :draw
  defp parse_letter("Z", :part_2), do: :win

  defp score_round({opponent, self}) do
    score_shape(self) + score_outcome({opponent, self})
  end

  defp score_shape(:rock), do: 1
  defp score_shape(:paper), do: 2
  defp score_shape(:scissors), do: 3

  defp score_outcome({same, same}), do: 3
  defp score_outcome({:rock, :paper}), do: 6
  defp score_outcome({:paper, :scissors}), do: 6
  defp score_outcome({:scissors, :rock}), do: 6
  defp score_outcome({_, _}), do: 0

  defp insert_self_choice({opponent, outcome}) do
    scores = %{win: 6, draw: 3, loss: 0}
    required_outcome_score = scores[outcome]
    possible_moves = [:rock, :paper, :scissors]

    self_choice =
      Enum.find(possible_moves, fn move ->
        score_outcome({opponent, move}) == required_outcome_score
      end)

    {opponent, self_choice}
  end
end
