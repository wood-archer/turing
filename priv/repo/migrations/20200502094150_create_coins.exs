defmodule Turing.Repo.Migrations.CreateCoinAccountss do
  use Ecto.Migration

  def change do
    create table(:coin_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :balance, :integer

      timestamps()
    end
  end
end
