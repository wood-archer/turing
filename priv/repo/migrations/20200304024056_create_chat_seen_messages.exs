defmodule Turing.Repo.Migrations.CreateChatSeenMessages do
  use Ecto.Migration

  def change do
    create table(:chat_seen_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :message_id, references(:chat_messages, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:chat_seen_messages, [:user_id])
    create index(:chat_seen_messages, [:message_id])

    create unique_index(:chat_seen_messages, [:user_id, :message_id])
  end
end
