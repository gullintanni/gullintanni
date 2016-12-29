use Mix.Config

config :logger,
  utc_log: true

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n"

import_config "#{Mix.env}.exs"
