defmodule Turing.Accounts.UserTest do
  use Turing.DataCase

  alias Turing.Accounts.User

  @valid_attrs %{
    first_name: "some first_name",
    last_name: "some last_name"
  }

  @invalid_attrs %{
    first_name: nil,
    last_name: nil
  }

  describe "changeset" do
    test "creates a changeset with valid data" do
      assert %Ecto.Changeset{valid?: true} = User.changeset_for_create(%User{}, @valid_attrs)
    end

    test "creates a changeset with invalid data" do
      assert %Ecto.Changeset{valid?: false} = User.changeset_for_create(%User{}, @invalid_attrs)
    end
  end
end
