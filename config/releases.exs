import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
signing_salt = System.fetch_env!("LIVE_VIEW_SIGNING_SALT")

config :chippy, ChippyWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4000],
  url: [
    host: System.get_env("HOSTNAME") || "example.com",
    port: System.get_env("EXTERNAL_PORT") || 80
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: secret_key_base,
  live_view: [
    signing_salt: signing_salt
  ],
  server: true

config :chippy, Chippy.Repo, url: System.get_env("DATABASE_URL")

config :logger, :console,
  level: :info,
  format: "$date $time $metadata[$level] $message\n"
