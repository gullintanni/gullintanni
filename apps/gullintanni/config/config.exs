use Mix.Config

config :logger,
  utc_log: true

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n"

#config :gullintanni
#  bind_ip: "0.0.0.0",
#  bind_port: 13931

config :gullintanni, :pipeline,
  my_project:
    [
      provider: Gullintanni.Providers.GitHub,
      provider_auth_token: {:system, "GULBOT_PROVIDER_AUTH_TOKEN"},
      repo_owner: {:system, "GULBOT_REPO_OWNER"},
      repo_name: {:system, "GULBOT_REPO_NAME"},
      worker: Gullintanni.Workers.TravisCI,
      worker_auth_token: {:system, "GULBOT_WORKER_AUTH_TOKEN"},
    ]

import_config "#{Mix.env}.exs"
