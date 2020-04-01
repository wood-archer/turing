defmodule Turing.Graphql.Schema do
  @moduledoc """
  Provides Graphql Schema functions
  """

  use Absinthe.Schema
  import_types(Turing.Graphql.Schema.Types)

  query do
    @desc "Get current user"
    field(:current_user, type: :user) do
      resolve(&Turing.Graphql.Resolvers.User.current/2)
    end
  end

  @desc "Update user params"
  input_object(:update_user_params) do
    field(:first_name, non_null(:string))
    field(:last_name, :string)
    field(:credential, :update_credential_params)
  end

  @desc "Create credentials params"
  input_object :create_credential_params do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
    field(:password_confirmation, non_null(:string))
  end

  @desc "Update credentials params"
  input_object :update_credential_params do
    field(:email, :string)
    field(:username, :string)
    field(:password, :string)
    field(:password_confirmation, :string)
  end

  mutation do
    @desc "Sign up"
    field(:signup, type: :user) do
      arg(:first_name, non_null(:string))
      arg(:credential, non_null(:create_credential_params))

      resolve(&Turing.Graphql.Resolvers.Auth.sign_up/2)
    end

    @desc "Log in"
    field(:login, :auth_token) do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Turing.Graphql.Resolvers.Auth.sign_in/2)
    end

    @desc "Sign out"
    field(:logout, :message) do
      resolve(&Turing.Graphql.Resolvers.Auth.sign_out/2)
    end

    @desc "Update user"
    field(:update_user, type: :user) do
      arg(:user, :update_user_params)

      resolve(&Turing.Graphql.Resolvers.User.update/2)
    end
  end
end
