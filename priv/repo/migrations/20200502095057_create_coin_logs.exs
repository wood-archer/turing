defmodule Turing.Repo.Migrations.CreateCoinLogs do
  use Ecto.Migration

  def change do
    create table(:coin_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :coins, :integer
      add :notes, :string
      add :coin_account_id, references(:coin_accounts, on_delete: :nothing, type: :binary_id)
      add :bid_id, references(:bids, on_delete: :nothing, type: :binary_id)

      timestamps()
    end
  end
end
