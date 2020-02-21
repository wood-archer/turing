defmodule Turing.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Turing.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "credentials" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    belongs_to(:user, User)

    timestamps()
  end

  @required_fields ~w(email password password_confirmation user_id)a

  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, @required_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_required([:email])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password")
    |> hash_password()
    |> foreign_key_constraint(:user_id)
    |> downcase_email()
    |> unique_constraint(:email)
  end

  @doc false
  def changeset_for_create(%Credential{} = credential, attrs) do
    credential
    |> changeset(attrs)
    |> validate_required([:password, :password_confirmation, :user_id])
  end

  @doc false
  def changeset_for_update(%Credential{} = credential, attrs) do
    credential
    |> changeset(attrs)
  end

  @doc false
  def changeset_for_validation(%Credential{} = credential, attrs) do
    credential
    |> changeset(attrs)
    |> validate_required([:password, :password_confirmation])
  end

  defp downcase_email(%Ecto.Changeset{valid?: true} = changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end

  defp downcase_email(%Ecto.Changeset{valid?: true, changes: %{email: nil}} = changeset), do: changeset

  defp downcase_email(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{email: _email}} = changeset), do: changeset

  defp hash_password(%Ecto.Changeset{valid?: false} = changeset), do: changeset
end
