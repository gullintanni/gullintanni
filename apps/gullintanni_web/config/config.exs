use Mix.Config

config :logger,
  utc_log: true

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n"

#config :gullintanni_web,
#  bind_ip: "127.0.0.1",
#  bind_port: 13980

import_config "#{Mix.env}.exs"
