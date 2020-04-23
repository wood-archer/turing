defmodule Turing.Game.CoinAccount do
  use Ecto.Schema
  import Ecto.Changeset

  alias Turing.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "coin_accounts" do
    field :balance, :integer
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(coin_account, attrs) do
    coin_account
    |> cast(attrs, [:user_id, :balance])
    |> validate_required([:user_id, :balance])
  end
end
