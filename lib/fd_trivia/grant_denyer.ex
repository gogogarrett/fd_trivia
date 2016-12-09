defmodule FdTrivia.GrantDenyer do
  @moduledoc """
  Responsible for checking the correctness of an answer
  """

  def correct_answer?({question, answer}, attempt) do
    normalize(answer) == normalize(attempt)
  end

  # should we have a bit more strict way to normalize question submissions?
  defp normalize(word), do: String.downcase(word)
end
