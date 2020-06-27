import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chippy, ChippyWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :chippy, Chippy.Repo,
  url: System.get_env("DATABASE_URL") || "postgres://postgres:postgres@localhost/chippy_test",
  pool: Ecto.Adapters.SQL.Sandbox

# Allow config to be overriden locally
import_config "test.secret.exs"
