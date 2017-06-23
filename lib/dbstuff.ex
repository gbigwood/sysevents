defmodule Sysevents.Repo do
  use Ecto.Repo,
    otp_app: :sysevents,
    adapter: Sqlite.Ecto
end

defmodule Event do
  use Ecto.Model

  schema "events" do
    # id field is implicit
    field :event_id, :string
    field :parent_id, :string
    field :type, :string
  end
end
