defmodule Gullintanni.Platform.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     version: "0.1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Docs
     name: "Gullintanni",
     source_url: "https://github.com/gullintanni/gullintanni",
     homepage_url: "https://gullintanni.github.io/gullintanni/",
     docs: [logo: "priv/static/images/logo.png",
            main: "readme",
            extras: ["README.md": [title: "README"],
                     "pages/Cheatsheet.md": [title: "Cheatsheet"],
                     "CONTRIBUTING.md": [title: "Contributing"]]]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    []
  end
end
