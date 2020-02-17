defmodule Turing.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Turing.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "credentials" do
    field(:email, :string)
    field(:password, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :user_id])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password")
    |> foreign_key_constraint(:user_id)
    |> hash_password()
    |> downcase_email()
    |> unique_constraint(:email)
  end


  defp downcase_email(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp downcase_email(%Ecto.Changeset{valid?: true} = changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password, Bcrypt.hash_pwd_salt(pass))

      _ ->
        changeset

    end
  end
end
