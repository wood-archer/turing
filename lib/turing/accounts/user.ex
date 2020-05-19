defmodule Turing.Accounts.User do
  @moduledoc """
  Provides User functions
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Turing.Accounts.Credential
  alias Turing.Chat.ConversationMember
  alias Turing.Game.CoinAccount

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:is_bot, :boolean, default: false)
    has_one(:credential, Credential, on_replace: :update)
    has_one(:coin_account, CoinAccount, on_replace: :update)

    has_many(:conversation_members, ConversationMember)
    has_many(:conversations, through: [:conversation_members, :conversation])

    timestamps()
  end

  @required_fields ~w(first_name)a
  @optional_fields ~w(last_name is_bot)a

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:credential)
  end

  def changeset_for_create(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required(@required_fields)
  end

  def changeset_for_update(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required(@required_fields)
  end
end
