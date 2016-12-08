defmodule FdTrivia.SurveySays do
  use GenServer

  @questions [
    {"System-Question: Who is the best?", "Garrett"},
    {"System-Question: Where am I?", "Work"},
    {"System-Question: What's for dinner?", "Sandwich"},
  ]

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_flowdock_message(msg) do
    GenServer.cast(__MODULE__, msg)
  end

  def init(:ok) do
    :timer.send_interval(10_000, :send_question)

    state = %{
      current_question: Enum.random(@questions)
    }
    {:ok, state}
  end

  def handle_cast(%{"app" => "chat", "content" => content} = msg, %{current_question: question} = state) do
    cond do
      # hack for the time being to ignore our own bot messages
      String.starts_with?(content, "System-Question:") ->
        {:noreply, state}
      true ->
        IO.inspect(elem(question, 1))
        IO.inspect(content)

        if elem(question, 1) == content do
          FlowdockClient.Sender.send_message("testttt", "System-Question: Good job!")
          new_state = %{state | current_question: Enum.random(@questions)}
          IO.inspect(new_state)
          {:noreply, new_state}
        else
          {:noreply, state}
        end
    end
  end

  def handle_info(:send_question,  %{current_question: {question, answer}} = state) do
    FlowdockClient.Sender.send_message("testttt", question)
    {:noreply, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end
end
