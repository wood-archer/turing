defmodule Turing.Accounts do

  alias Turing.Accounts.Credential

  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset_for_validation(credential, attrs)
  end
end
