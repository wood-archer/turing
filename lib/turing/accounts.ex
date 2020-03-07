defmodule Turing.Accounts do

  alias Turing.Accounts.{Credential, User}
  alias Turing.Repo

  def change_credential_session(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset_for_session(credential, attrs)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset_for_create(user, attrs)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset_for_create(attrs)
    |> Repo.insert()
  end

  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset_for_create(attrs)
    |> Repo.insert()
  end
end
