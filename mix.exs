defmodule Gullintanni.Mixfile do
  use Mix.Project

  def project do
    [app: :gullintanni,
     version: "0.1.0",
     elixir: "~> 1.3",
     name: "Gullintanni Bot",
     source_url: "https://github.com/gullintanni/gullintanni",
     homepage_url: "https://gullintanni.github.io/gullintanni/",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :tentacat],
     mod: {Gullintanni, []}]
  end

  defp deps do
    [{:dialyxir, "~> 0.3", only: :dev},
     {:ex_doc, "~> 0.12", only: :dev},
     {:tentacat, "~> 0.5"}]
  end
end
