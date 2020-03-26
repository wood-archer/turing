defmodule Turing.Auth do
  alias Turing.Repo
  alias Turing.Accounts.Credential

  def validate_credentials(email, password) do
    credential =
      email
      |> String.downcase()
      |> get_credential_by_email()

    case credential do
      nil ->
        {:error, [email: {"User does not exist.", []}]}

      _ ->
        password
        |> Bcrypt.verify_pass(credential.password_hash)
        |> case do
          true ->
            %Credential{user: user} = Repo.preload(credential, :user)

            {:ok, user}

          _ ->
            {:error, [password: {"Invalid password.", []}]}
        end
    end
  end

  defp get_credential_by_email(email), do: Repo.get_by(Credential, email: email)
end
