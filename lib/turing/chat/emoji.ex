defmodule Turing.Chat.Emoji do
  @moduledoc """
  Provides Emoji functions
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chat_emojis" do
    field :key, :string
    field :unicode, :string

    timestamps()
  end

  @doc false
  def changeset(emoji, attrs) do
    emoji
    |> cast(attrs, [:key, :unicode])
    |> validate_required([:key, :unicode])
  end
end
