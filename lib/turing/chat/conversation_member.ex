defmodule Turing.Chat.ConversationMember do
  @moduledoc """
  Provides ConversationMember functions
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Accounts.User
  alias Turing.Chat.Conversation

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_conversation_members" do
    field :owner, :boolean, default: false

    belongs_to :user, User
    belongs_to :conversation, Conversation

    timestamps()
  end

  @doc false
  def changeset(conversation_member, attrs) do
    conversation_member
    |> cast(attrs, [:owner, :user_id, :conversation_id])
    |> validate_required([:owner, :user_id])
    |> unique_constraint(:user, name: :chat_conversation_members_conversation_id_user_id_index)
    |> unique_constraint(:conversation_id, name: :chat_conversation_members_owner)
  end
end
