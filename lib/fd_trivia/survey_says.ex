defmodule FdTrivia.SurveySays do
  use GenServer

  @question_interval 10_000
  @update_user_interval 10_000
  @flow_name Application.get_env(:fd_trivia, :flow_name, "testttt")

  alias FdTrivia.{
    GrantDenyer,
    Bank,
    ScoreBoard,
  }
  alias FdTrivia.Service.{
    FetchFlowUsers,
  }
  alias FdTrivia.UI.{
    Leaderboard,
    Bot
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
    send_message(state.flow, Bot.question(question))
    {:noreply, state}
  end

  def handle_info(:update_user_list, state) do
    new_state = %{state | players: FetchFlowUsers.get_users}
    {:noreply, new_state}
  end

  def handle_info(:send_welcome_message, state) do
    send_message(state.flow, Bot.welcome)
    {:noreply, state}
  end

  def handle_cast(_, state), do: {:noreply, state}

  defp send_message(flow_name, message), do: FlowdockClient.Sender.send_message(flow_name, message)

  # Logic to match on the incomming messages
  defp leaderboard?("bot:scores" <> _content), do: true
  defp leaderboard?(_), do: false

  defp bot_message?("bot:" <> _content), do: true
  defp bot_message?(_), do: false

  # Logic to handle each message type
  defp print_leaderboard(state) do
    score_message = Leaderboard.print(state)
    send_message(state.flow, Bot.message(score_message))
  end

  defp process_answer(question, content, user, state) do
    if GrantDenyer.correct_answer?(question, content) do
      send_message(state.flow, Bot.correct_answer)

      %{state |
        current_question: Bank.next_question,
        scores: ScoreBoard.update(state.scores, user),
      }
    else
      state
    end
  end
end
