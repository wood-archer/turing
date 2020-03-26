defmodule Turing.Repo.Migrations.AddUsernameToCredentials do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      add :username, :string
    end

    create unique_index(:credentials, [:username])
  end
end
