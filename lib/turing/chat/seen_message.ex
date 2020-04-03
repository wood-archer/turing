defmodule Turing.Chat.SeenMessage do
  @moduledoc """
  Provides SeenMessage functions
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Accounts.User
  alias Turing.Chat.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_seen_messages" do
    belongs_to :user, User
    belongs_to :message, Message

    timestamps()
  end

  @doc false
  def changeset(seen_message, attrs) do
    seen_message
    |> cast(attrs, [:user_id, :message_id])
    |> validate_required([:user_id, :message_id])
  end
end
