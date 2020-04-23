defmodule Turing.Game.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Accounts.User
  alias Turing.Chat.Conversation

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bids" do
    field :coins, :integer
    field :guess, :string
    field :result, :string, default: "PENDING"
    belongs_to :user, User
    belongs_to :conversation, Conversation

    timestamps()
  end

  @doc false
  def changeset(bid, attrs) do
    bid
    |> cast(attrs, [:conversation_id, :user_id, :coins, :result, :guess])
    |> validate_required([:conversation_id, :user_id, :coins, :result, :guess])
  end
end
