defmodule KojimaBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :kojimabot,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KojimaBot.Application, []}
    ]
  end

  def deps do
    [
      {:nostrum, "~> 0.10"},
      {:httpoison, "~> 2.0"}
    ]
  end
end
