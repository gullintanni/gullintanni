# Override configuration settings when running in the `:test` environment.
use Mix.Config

config :gullintanni,
  enable_http_workers: false,
  enable_load_pipelines: false
