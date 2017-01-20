defmodule FdTrivia.UI.Bot do
  @moduledoc """
  A collection of utils around all messages the bot can send back to the client

  We prepend every message with `bot:` so the system can tell it's a system message
  """

  def welcome do
    "bot: Welcome to Trivia!"
  end

  def question(question) do
    "bot::question: #{question}"
  end

  def correct_answer do
    "bot:exclamation: Good job!"
  end

  @doc """
  general purpose function to prepend `bot:` to a message
  """
  def message(message) do
    "bot: #{message}"
  end
end
