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
    password_confirmation: nil,
    user_id: nil
  }

  describe "changeset_for_create" do
    test "downcases email with valid data" do
      assert assert %Ecto.Changeset{
                      changes: %{email: email}
                    } = %Credential{} |> Credential.changeset_for_create(@valid_attrs)

      assert email == "john@doe.com"
    end

    test "does not downcases email when changeset is invalid" do
      assert %Ecto.Changeset{
               changes: %{email: email}
             } =
               %Credential{}
               |> Credential.changeset_for_create(Map.put(@invalid_attrs, :email, "JOHNdoe.com"))

      assert email == "JOHNdoe.com"
    end

    test "does not downcases email when it's nil" do
      assert %Ecto.Changeset{
               changes: %{}
             } = %Credential{} |> Credential.changeset_for_create(@invalid_attrs)
    end
  end
end
