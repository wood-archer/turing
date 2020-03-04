defmodule Turing.Repo.Migrations.CreateChatEmojis do
  use Ecto.Migration

  def change do
    create table(:chat_emojis, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :key, :string, null: false
      add :unicode, :string, null: false

      timestamps()
    end

  end
end
