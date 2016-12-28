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
                     "CONTRIBUTING.md": [title: "Contributing"]]],

     # Tests
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test]]
  end

  defp deps do
    []
  end
end
