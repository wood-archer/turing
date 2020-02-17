defmodule Turing.Graphql.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Turing.Repo

  @desc "User"
  object(:user) do
    field(:id, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:credential, :credential, resolve: assoc(:credential))
    field(:inserted_at, :string)
    field(:updated_at, :string)
  end

  @desc "Credential"
  object(:credential) do
    field(:id, :string)
    field(:email, :string)
    field(:password, :string)
    field(:password_confirmation, :string)
    field(:user_id, :string)
    field(:inserted_at, :string)
    field(:updated_at, :string)
  end

  @desc "Auth token"
  object :auth_token do
    field(:token, :string)
  end

  @desc "API response message"
  object :message do
    field(:message, :string)
  end
end
