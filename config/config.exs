# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :turing,
  ecto_repos: [Turing.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :turing, TuringWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Fad03a+diZpRXHZigyHiyJtBZb9TZiHdkEWqvhbER0bUmQWducxZ2voOXwwpxdhf",
  render_errors: [view: TuringWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Turing.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "LIlgBfJ9j7xLJ6Almy982/ZydK/9y0vd"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :turing, Turing.Auth.Guardian,
  issuer: "Turing",
  verify_issuer: true

config :guardian, Guardian.DB,
  repo: Turing.Repo,
  schema_name: "guardian_tokens",
  # 24hx60min=1440 minutes (once a day)
  sweep_interval: 1440

config :cors_plug,
  origin: "*",
  max_age: 86400,
  # allow_headers: ["accept", "content-type", "authorization"],
  methods: ["GET", "POST"],
  log: [rejected: :error, invalid: :warn, accepted: :debug]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
