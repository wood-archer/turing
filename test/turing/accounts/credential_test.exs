defmodule Turing.Accounts.CredentialTest do
  use Turing.DataCase

  alias Turing.Accounts.Credential

  @valid_attrs %{
    email: "JOHN@DOE.COM",
    password: "123456",
    user_id: Ecto.UUID.generate()
  }

  @invalid_attrs %{
    email: nil,
    password: nil,
    user_id: nil
  }

  describe "changeset" do
    test "downcases email with valid data" do
      assert assert %Ecto.Changeset{
        changes: %{email: email},
      } = %Credential{} |> Credential.changeset(@valid_attrs)
      assert email == "john@doe.com"
    end

    test "does not downcases email when changeset is invalid" do
      assert %Ecto.Changeset{
        changes: %{email: email}
      } = %Credential{} |> Credential.changeset(Map.put(@invalid_attrs, :email, "JOHN@doe.com"))

      assert email == "JOHN@doe.com"
    end

    test "does not downcases email when it's nil" do
      assert %Ecto.Changeset{
        changes: %{},
      } = %Credential{} |> Credential.changeset(@invalid_attrs)
    end
  end

end