defmodule Feedme.Repo do
  use Ecto.Repo,
    otp_app: :feedme,
    adapter: Ecto.Adapters.Postgres
end
