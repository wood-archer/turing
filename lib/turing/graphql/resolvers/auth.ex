defmodule Turing.Graphql.Resolvers.Auth do
  alias Turing.Repo
  alias Turing.Accounts.{Credential, User}
  alias TuringWeb.ErrorHelpers

  def sign_up(args, _info) do
    changeset = User.changeset_for_create(%User{}, args)

    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, user}

      {:error, changeset} ->
        errors = changeset.errors ++ changeset.changes.credential.errors

        {
          :error,
          ErrorHelpers.handle_changeset_errors(errors)
        }
    end
  end

  def sign_in(args, _info) do
    credential =
      Credential
      |> Repo.get_by(email: args[:email])
      |> Repo.preload(:user)

    case verify_pass(credential, args[:password]) do
      true -> generate_token(credential.user)
      _ -> {:error, "Invalid credentials"}
    end
  end

  def sign_out(_args, %{context: %{current_user: _current_user, metadata: %{token: token}}}) do
    with {:ok, _claims} <- Turing.Auth.Guardian.revoke(token) do
      {:ok, %{message: "You have been logged out!"}}
    end
  end

  def sign_out(_, _), do: {:error, "Access denied"}

  defp verify_pass(credential, password) do
    case credential do
      nil -> false
      _ -> Bcrypt.verify_pass(password, credential.password_hash)
    end
  end

  defp generate_token(user) do
    case Turing.Auth.Guardian.encode_and_sign(user) do
      nil -> {:error, "An Error occured creating the token"}
      {:ok, token, _full_claims} -> {:ok, %{token: token}}
    end
  end
end
