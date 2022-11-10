defmodule Continue.Repo do
  use Ecto.Repo,
    otp_app: :continue,
    adapter: Ecto.Adapters.Postgres
end
