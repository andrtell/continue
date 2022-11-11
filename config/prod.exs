import Config

# Cache manifest

config :continue, ContinueWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Logflare

config :logger,
  level: :info,
  backends: [LogflareLogger.HttpBackend]

# Host / SSL

config :continue, ContinueWeb.Endpoint, force_ssl: []
