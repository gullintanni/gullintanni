use Mix.Config

config :logger,
  utc_log: true

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n"

#config :gullintanni, :status_page,
#  bind_ip: "127.0.0.1",
#  bind_port: 13980

#config :gullintanni, :webhook,
#  bind_ip: "0.0.0.0",
#  bind_port: 13931

config :gullintanni, :pipeline,
  my_project:
    [
      repo_provider: Gullintanni.Providers.GitHub,
      repo_owner: {:system, "GULBOT_REPO_OWNER"},
      repo_name: {:system, "GULBOT_REPO_NAME"},
      provider_auth_token: {:system, "GULBOT_PROVIDER_AUTH_TOKEN"},
      worker: Gullintanni.Workers.TravisCI,
    ]

import_config "#{Mix.env}.exs"
