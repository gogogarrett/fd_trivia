defmodule FdTrivia.GrantDenyer do
  @moduledoc """
  Responsible for checking the correctness of an answer
  """

  def correct_answer?({question, answer}, attempt) do
    normalize(answer) == normalize(attempt)
  end

  defp normalize(word), do: String.downcase(word)
end

defmodule FdTrivia.Bank do
  @moduledoc """
  Provides the questions and answers
  """

  @questions [
    {"Who is the best?", "Garrett"},
    {"Where am I?", "Work"},
    {"What's for dinner?", "Sandwich"},
  ]

  def next_question, do: Enum.random(@questions)
end

defmodule FdTrivia.ScoreBoard do
  @moduledoc """
  Provides the functions to manage the scoreboard
  """

  def update(scores, user_id) do
    user_id_int = String.to_integer(user_id)
    scores
    |> Map.update(user_id_int, 1, &(&1 + 1))
  end
end

defmodule FdTrivia.FetchFlowUsers do
  # figure out what to do with this.. put back into flowdock_client?
  @api_token Application.get_env(:flowdock_client, :api_token)

  # fix this hardcoding
  def get_users do
    with response <- fetch,
         json_body <- Map.get(response, :body),
         {:ok, players_json} <- Poison.decode(json_body),
         players = Enum.map(players_json, &Map.take(&1, ["id", "nick"]))
    do
      players
    else
      _ ->
        IO.inspect("error loading users")
        []
    end
  end

  defp fetch do
    HTTPotion.get(
      "https://api.flowdock.com/flows/blake/testttt/users",
      [
        headers: ["Authorization": prepare_auth_header(@api_token)]
      ]
    )
  end

  defp prepare_auth_header(string) do
    auth_string = string |> Base.encode64
    "Basic #{auth_string}"
  end
end

defmodule FdTrivia.UI.Leaderboard do
  @trophy "🏆"
  @flag "🏁"

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

defmodule FdTrivia.SurveySays do
  use GenServer

  @question_interval 10_000
  @update_user_interval 10_000
  @flow_name Application.get_env(:fd_trivia, :flow_name, "testttt")

  alias FdTrivia.{
    GrantDenyer,
    Bank,
    ScoreBoard,
    FetchFlowUsers,
  }
  alias FdTrivia.UI.{
    Leaderboard
  }

  def start_link, do: GenServer.start_link(__MODULE__, @flow_name, name: __MODULE__)
  def handle_flowdock_message(msg), do: GenServer.cast(__MODULE__, msg)

  def init(flow_name) do
    :timer.send_after(1_000, :send_welcome_message)
    :timer.send_interval(@update_user_interval, :update_user_list)
    :timer.send_interval(@question_interval, :send_question)

    state = %{
      current_question: Bank.next_question,
      flow: flow_name,
      players: [],
      scores: %{},
    }
    {:ok, state}
  end

  def handle_cast(%{"app" => "chat", "content" => content, "user" => user} = msg, %{current_question: question} = state) do
    cond do
      leaderboard?(content) ->
        print_leaderboard(state)
        {:noreply, state}
      bot_message?(content) ->
        {:noreply, state}
      true ->
        new_state = process_answer(question, content, user, state)
        {:noreply, new_state}
    end
  end

  def handle_info(:send_question, %{current_question: {question, _answer}} = state) do
    send_message(state.flow, "bot:question: #{question}")
    {:noreply, state}
  end

  def handle_info(:update_user_list, state) do
    new_state = %{state | players: FetchFlowUsers.get_users}
    {:noreply, new_state}
  end

  def handle_info(:send_welcome_message, state) do
    send_message(state.flow, "bot: Welcome to Trivia!")
    {:noreply, state}
  end

  def handle_cast(_, state), do: {:noreply, state}

  defp send_message(flow_name, message), do: FlowdockClient.Sender.send_message(flow_name, message)

  # Logic to match on the incomming messages
  defp leaderboard?("bot:scores" <> _content), do: true
  defp leaderboard?(_), do: false

  defp bot_message?("bot:" <> _content), do: true
  defp bot_message?(_), do: false

  # Logic to handle each message Type

  defp print_leaderboard(state) do
    score_message = Leaderboard.print(state)
    send_message(state.flow, "bot:\n#{score_message}")
  end

  defp process_answer(question, content, user, state) do
    if GrantDenyer.correct_answer?(question, content) do
      send_message(state.flow, "bot:exclamation: Good job!")

      %{state |
        current_question: Bank.next_question,
        scores: ScoreBoard.update(state.scores, user),
      }
    else
      state
    end
  end
end
