defmodule FdTrivia.SurveySays do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_flowdock_message(msg) do
    GenServer.cast(__MODULE__, msg)
  end

  def init(:ok) do
    :timer.send_interval(10_000, :send_question)
    {:ok, %{count: 0, last_word: ""}}
  end

  def handle_cast(%{"app" => "chat", "content" => content} = msg, state) do
    cond do
      # hack for the time being to ignore our own bot messages
      String.starts_with?(content, "System-Question:") ->
        {:noreply, state}
      true ->
        new_state = %{state | count: state.count + 1, last_word: content}
        IO.inspect(new_state)
        {:noreply, new_state}
    end
  end

  def handle_info(:send_question, state) do
    FlowdockClient.Sender.send_message("testttt", "System-Question: Who is the best?")
    {:noreply, state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end
end
