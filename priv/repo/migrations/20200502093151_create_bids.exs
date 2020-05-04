defmodule Turing.Repo.Migrations.CreateBids do
  use Ecto.Migration

  def change do
    create table(:bids, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :conversation_id, references(:chat_conversations, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :coins, :integer
      add :result, :string
      add :guess, :string

      timestamps()
    end

    create index(:bids, [:conversation_id])
    create index(:bids, [:user_id])
  end
end
