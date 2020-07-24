import Config

config :chippy,
  ecto_repos: [Chippy.Repo]

# Configures the endpoint
config :chippy, ChippyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZjS5E1330qBwwf/FXn1ZJ3XBYOQYw6R7jU7HyNBl6JKRfwdZ+Me9FHpHGalqtszr",
  render_errors: [view: ChippyWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Chippy.PubSub,
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
if File.exists?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
