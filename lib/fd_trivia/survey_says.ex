defmodule FdTrivia.SurveySays do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_flowdock_message(msg) do
    GenServer.cast(__MODULE__, msg)
  end

  def init(:ok) do
    {:ok, %{count: 0, last_word: ""}}
  end

  def handle_cast(%{"app" => "chat"} = msg, state) do
    new_state = %{state | count: state.count + 1, last_word: msg["content"]}
    IO.inspect(new_state)
    {:noreply, new_state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end
end
