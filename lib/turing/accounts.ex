defmodule Turing.Accounts do

  alias Turing.Accounts.Credential

  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset(credential, attrs)
  end
end
