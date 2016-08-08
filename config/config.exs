use Mix.Config

config :logger,
  utc_log: true

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n"

config :gullintanni, :pipeline,
  my_project:
    [
      provider: Gullintanni.Providers.GitHub,
      provider_auth_token: {:system, "GULBOT_PROVIDER_AUTH_TOKEN"},
      repo_owner: {:system, "GULBOT_REPO_OWNER"},
      repo_name: {:system, "GULBOT_REPO_NAME"},
    ]
