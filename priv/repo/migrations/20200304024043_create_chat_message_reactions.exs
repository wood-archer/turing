defmodule Turing.Repo.Migrations.CreateChatMessageReactions do
  use Ecto.Migration

  def change do
    create table(:chat_message_reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :message_id, references(:chat_messages, on_delete: :nothing, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :emoji_id, references(:chat_emojis, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:chat_message_reactions, [:message_id])
    create index(:chat_message_reactions, [:user_id])
    create index(:chat_message_reactions, [:emoji_id])

    create unique_index(:chat_message_reactions, [:user_id, :message_id, :emoji_id])
  end
end
