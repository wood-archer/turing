defmodule Turing.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Turing.Accounts.Credential

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)

    has_one(:credential, Credential, on_replace: :update)

    timestamps()
  end

  @required_fields ~w(first_name)a
  @optional_fields ~w(last_name)a

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:credential)
  end

  def changeset_for_create(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required(@required_fields)
  end

  def changeset_for_update(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required(@required_fields)
  end
end
