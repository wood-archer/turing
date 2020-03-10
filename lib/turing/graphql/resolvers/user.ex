defmodule Turing.Graphql.Resolvers.User do
  alias Turing.Accounts.User
  alias Turing.Repo
  alias TuringWeb.ErrorHelpers

  def current(_, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def current(_, _) do
    {:error, "Access denied"}
  end

  def update(%{user: user_params}, %{context: %{current_user: current_user}}) do
    changeset =
      current_user
      |> Repo.preload(:credential)
      |> User.changeset_for_update(user_params)

    case Repo.update(changeset) do
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

  def update(_, _) do
    {:error, "Access denied"}
  end
end
