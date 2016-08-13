defmodule Gullintanni.Mixfile do
  use Mix.Project

  def project do
    [app: :gullintanni,
     version: "0.1.0",
     elixir: "~> 1.3",
     name: "Gullintanni",
     source_url: "https://github.com/gullintanni/gullintanni",
     homepage_url: "https://gullintanni.github.io/gullintanni/",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [logo: "priv/images/logo.png",
            main: "README",
            extras: ["README.md", "pages/Cheatsheet.md"]]]
  end

  def application do
    [mod: {Gullintanni, []},
     applications: [:cowboy, :logger, :plug, :tentacat],
     env: [enable_http_workers: true,
           webhook: [bind_ip: "0.0.0.0", bind_port: 13931]]]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:dialyxir, "~> 0.3", only: :dev},
     {:ex_doc, "~> 0.12", only: :dev},
     {:gen_stage, "~> 0.5"},
     {:poison, "~> 2.2"},
     {:plug, "~> 1.2"},
     {:tentacat, "~> 0.5"}]
  end
end
