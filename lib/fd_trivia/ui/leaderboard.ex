defmodule FdTrivia.UI.Leaderboard do
  @moduledoc """
  A UI util to wrap players and scores in some presentation emojis
  """

  @trophy "🏆"
  @flag "🏁"

  @doc """
  Given a data structure with players and scores, we return a friendly string joined with new lines
  to represent the players scores
  """
  def print(%{scores: scores, players: players} = state) do
    [
      symbol_bar(@trophy),
      symbol_bar(@flag),
      players_scores(players, scores),
    ]
    |> Enum.join("\n")
  end

  defp symbol_bar(symbol), do: (1..10) |> Enum.map(fn(_) -> symbol end) |> Enum.join

  defp players_scores(players, scores) do
    players
    |> Enum.flat_map(fn(player) ->
      player_score(player, scores)
    end)
    |> Enum.join("\n")
  end

  defp player_score(%{"nick" => nick, "id" => player_id}, scores) do
    player_score = scores[player_id]
    [":space_invader:#{nick}:arrow_forward:#{player_score}:sparkles:"]
  end
end
