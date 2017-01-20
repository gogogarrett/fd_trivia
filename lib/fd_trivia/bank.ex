defmodule FdTrivia.Bank do
  @moduledoc """
  Provides the questions and answers
  """

  def start_link do
    Agent.start_link(&fetch_trivia/0, name: :trivia_bank)
  end

  # should we have some ranking to ensure we don't get the same random question back to back?
  def next_question do
    Agent.get(:trivia_bank, &(&1))
    |> Enum.random()
  end

  defp update_questions do
    Agent.update(:trivia_bank, fetch_trivia)
  end

  defp fetch_trivia, do: TriviaClient.random(100)
end
