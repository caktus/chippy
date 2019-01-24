defmodule Chippy.Repo do
  use Ecto.Repo,
    otp_app: :chippy,
    adapter: Ecto.Adapters.Postgres
end
