defmodule ParallelPrototype.MixProject do
  use Mix.Project

  def project do
    [
      app: :parallel_prototype,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive],
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      docs: [
        main: "ParallelPrototype",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/parallel_prototype/support"]
  defp elixirc_paths(_), do: ["lib"]
end
