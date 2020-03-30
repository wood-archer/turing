use Mix.Config

# Configure your database
config :turing, Turing.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER", "postgres"),
  password: System.get_env("DATA_DB_PASS", "postgres"),
  hostname: System.get_env("DATA_DB_HOST", "localhost"),
  database: "turing_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :turing, Turing.Auth.Guardian, secret_key: "guardian"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :turing, TuringWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Reduce the number of bcrypt, or pbkdf2, rounds so it
# does not slow down the tests.
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

unless System.get_env("GITHUB_ACTIONS") do
  import_config "#{Mix.env()}.secret.exs"
end
