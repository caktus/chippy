# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chippy,
  ecto_repos: [Chippy.Repo]

# Configures the endpoint
config :chippy, ChippyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZjS5E1330qBwwf/FXn1ZJ3XBYOQYw6R7jU7HyNBl6JKRfwdZ+Me9FHpHGalqtszr",
  render_errors: [view: ChippyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Chippy.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "f+vbVpQNIOm++4C/33LWT0Qq+aWj2Etu"
  ]

# Application settings
config :chippy,
  hours_per_chip: 4

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
