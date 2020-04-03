defmodule Turing.Chat.Conversation do
  @moduledoc """
  Provides Conversation functions
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Chat.{ConversationMember, Message}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_conversations" do
    field :title, :string

    has_many(:conversation_members, ConversationMember, on_replace: :delete)
    has_many(:users, through: [:conversation_members, :user])
    has_many(:messages, Message)

    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:title])
    |> validate_required(:title)
    |> cast_assoc(:conversation_members)
  end
end
