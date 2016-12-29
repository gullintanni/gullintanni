defmodule HardHat.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :hard_hat,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Docs
      name: "Hard Hat",
      docs: [
        main: "readme",
        extras: ["README.md": [title: "README"]],
      ],

      # Tests
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
    ]
  end

  def application() do
    [applications: [:httpoison, :logger]]
  end

  defp deps() do
    [
      {:httpoison, "~> 0.10"},
      {:poison, "~> 3.0"},

      {:credo, "~> 0.5", only: :dev},
      {:dialyxir, "~> 0.4", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},

      {:excoveralls, "~> 0.5", only: :test},
    ]
  end
end
