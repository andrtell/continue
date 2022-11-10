import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :continue, Continue.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "continue_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :continue, ContinueWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "esC4yJ5YFsYDnC6olaIw+vkx2wudzA0exmSdIGIhqC+qmGI6dhEk6NUbxL45pmN+",
  server: false

# In test we don't send emails.
config :continue, Continue.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
