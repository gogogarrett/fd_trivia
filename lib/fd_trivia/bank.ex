defmodule FdTrivia.Bank do
  @moduledoc """
  Provides the questions and answers
  """

  # we should look at fetching these somewhere dynamic.. perhaps use ets to store them?
  @questions [
    {"Who is the best?", "Garrett"},
    {"Where am I?", "Work"},
    {"What's for dinner?", "Sandwich"},
  ]

  # should we have some ranking to ensure we don't get the same random question back to back?
  def next_question, do: Enum.random(@questions)
end
