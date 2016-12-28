defmodule Gullintanni.Mixfile do
  use Mix.Project

  def project do
    [app: :gullintanni,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Tests
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test]]
  end

  def application do
    [mod: {Gullintanni, []},
     applications: [:cowboy, :gproc, :logger, :plug, :tentacat],
     env: [enable_http_workers: true,
           enable_load_pipelines: true,
           status_page: [bind_ip: "127.0.0.1", bind_port: 13980],
           webhook: [bind_ip: "0.0.0.0", bind_port: 13931]]]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:credo, "~> 0.5", only: :dev},
     {:dialyxir, "~> 0.4", only: :dev},
     {:ex_doc, "~> 0.14", only: :dev},
     {:excoveralls, "~> 0.5", only: :test},
     {:gen_stage, "~> 0.10"},
     {:gproc, "~> 0.6"},
     {:poison, "~> 3.0"},
     {:plug, "~> 1.3"},
     {:tentacat, "~> 0.5"}]
  end
end