defmodule FdTrivia.ScoreBoard do
  @moduledoc """
  Provides the functions to manage the scoreboard
  """

  @doc """
    Takes a map and updates a given key by 1

      # Example:
      iex> update(%{}, "1")
      > %{1: 1}

      iex> update(%{"1" => 2}, "1")
      > %{1: 3}

      iex> update(%{"1" => 2}, "5")
      > %{1: 2, 5: 1}
  """
  def update(scores, user_id) do
    user_id_int = String.to_integer(user_id)
    scores
    |> Map.update(user_id_int, 1, &(&1 + 1))
  end
end
