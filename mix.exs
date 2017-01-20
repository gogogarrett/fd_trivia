defmodule FdTrivia.Mixfile do
  use Mix.Project

  def project do
    [app: :fd_trivia,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :flowdock_client],
     mod: {FdTrivia, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:flowdock_client, path: "../flowdock_client"},
      {:trivia_client, git: "git@github.com:wiserfirst/trivia_client.git"}
    ]
  end
end
