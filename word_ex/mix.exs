defmodule WordEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :word_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {WordEx.Runtime.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dictionary, git: "https://github.com/paulogrupp/dictionary-ex.git", branch: "main"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:unicode_transform, "~> 0.3.0"}
    ]
  end
end
