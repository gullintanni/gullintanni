defmodule GullintanniWeb.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :gullintanni_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Docs
      name: "Gullintanni Web",
      docs: [
        logo: "priv/static/images/logo.png",
        main: "readme",
        extras: ["README.md": [title: "README"]],
      ],

      # Tests
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
    ]
  end

  def application() do
    [
      extra_applications: [:logger],
      mod: {GullintanniWeb.Application, []},
      env: [
        enable_http_workers: true,
        bind_ip: "127.0.0.1",
        bind_port: 13_980,
      ],
    ]
  end

  defp deps() do
    [
      {:cowboy, "~> 1.0"},
      {:gullintanni, in_umbrella: true},
      {:plug, "~> 1.3"},
      {:socket_address, "~> 0.2"},

      {:credo, "~> 0.5", only: :dev},
      {:dialyxir, "~> 0.4", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},

      {:excoveralls, "~> 0.5", only: :test},
    ]
  end
end
