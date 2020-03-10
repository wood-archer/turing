defmodule Turing.Repo.Migrations.CreateChatConversationMembers do
  use Ecto.Migration

  def change do
    create table(:chat_conversation_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :owner, :boolean, default: false, null: false
      add :conversation_id, references(:chat_conversations, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:chat_conversation_members, [:conversation_id])
    create index(:chat_conversation_members, [:user_id])

    # this ensures that one user can be associated with each conversation only once
    create unique_index(:chat_conversation_members, [:conversation_id, :user_id])
    # PostgreSQL partial index -- only created on the table's records with owner set
    # to true, which means that only one conversation member record with a given
    # conversation_id will ever be the conversation's owner.
    create unique_index(:chat_conversation_members, [:conversation_id],
             where: "owner = TRUE",
             name: "chat_conversation_members_owner"
           )
  end
end
