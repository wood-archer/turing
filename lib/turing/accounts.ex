defmodule Turing.Accounts do

  alias Turing.Accounts.Credential

  def change_credential_session(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset_for_session(credential, attrs)
  end
end
