defmodule Turing.Chat.Message do
  @moduledoc """
  Provides Message functions
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Accounts.User
  alias Turing.Chat.{Conversation, SeenMessage, MessageReaction}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_messages" do
    field :content, :string

    belongs_to :conversation, Conversation
    belongs_to :user, User

    has_many :seen_messages, SeenMessage
    has_many :message_reactions, MessageReaction

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :conversation_id, :user_id])
    |> validate_required([:content, :conversation_id, :user_id])
  end
end
