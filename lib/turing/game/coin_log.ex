defmodule Turing.Game.CoinLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Accounts.User
  alias Turing.Game.{CoinAccount, Bid}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "coin_logs" do
    belongs_to :bid, Bid
    belongs_to :coin_account, CoinAccount
    belongs_to :user, User
    field :coins, :integer
    field :notes, :string, default: "BID_WITHDRAW"

    timestamps()
  end

  @doc false
  def changeset(coin_log, attrs) do
    coin_log
    |> cast(attrs, [:user_id, :coins, :coin_account_id, :bid_id, :notes])
    |> validate_required([:user_id, :coins, :coin_account_id, :bid_id, :notes])
  end
end
