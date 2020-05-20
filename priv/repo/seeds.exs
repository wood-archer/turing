# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Turing.Repo.insert!(%Turing.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Turing.Accounts.{Credential, User}
alias Turing.Chat.{Conversation, ConversationMember}
alias Turing.{Accounts, Chat, Game}

{:ok, %User{id: u1_id}} =
  Accounts.create_user(%{first_name: "John", last_name: "Doe", is_bot: true})

{:ok, %Credential{}} =
  Accounts.create_credential(%{
    email: "john@doe.com",
    username: "john.doe",
    password: "123qweasd",
    password_confirmation: "123qweasd",
    user_id: u1_id
  })

{:ok, %User{id: u2_id}} =
  Accounts.create_user(%{first_name: "Jane", last_name: "Doe", is_bot: true})

{:ok, %Credential{}} =
  Accounts.create_credential(%{
    email: "jane@doe.com",
    username: "jane.doe",
    password: "123qweasd",
    password_confirmation: "123qweasd",
    user_id: u2_id
  })

{:ok, coin_account_u1} = Game.create_coin_account(%{user_id: u1_id, balance: 10000})
{:ok, coin_account_u2} = Game.create_coin_account(%{user_id: u2_id, balance: 10000})

{:ok, %Conversation{id: conv_id}} = Chat.create_conversation(%{title: "Modern Talking"})

{:ok, %ConversationMember{}} =
  Chat.create_conversation_member(%{conversation_id: conv_id, user_id: u1_id, owner: true})

{:ok, %ConversationMember{}} =
  Chat.create_conversation_member(%{conversation_id: conv_id, user_id: u2_id, owner: false})
