defmodule Turing.Accounts do
  @moduledoc """
  Provides Accounts functions
  """

  import Ecto.Query
  alias Turing.Accounts.{Credential, User}
  alias Turing.Game.CoinAccount
  alias Turing.Utils.Constants
  alias Turing.Repo
  alias Ecto.Multi
  @default_signup_coin_account_balance Constants.default_signup_coin_account_balance()

  def change_credential_session(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset_for_session(credential, attrs)
  end

  def change_credential_update(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset_for_update(credential, attrs)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset_for_create(user, attrs)
  end

  def change_user_for_update(%User{} = user, attrs \\ %{}) do
    User.changeset_for_update(user, attrs)
  end

  def get_user!(id), do: Repo.get(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset_for_create(attrs)
    |> Repo.insert()
  end

  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset_for_create(attrs)
    |> Repo.insert()
  end

  def setup_user(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:create_user, User.changeset_for_create(%User{}, attrs))
    |> Multi.insert(:create_coin_account, fn %{create_user: user} ->
      CoinAccount.changeset(%CoinAccount{}, %{
        user_id: user.id,
        balance: @default_signup_coin_account_balance
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_user: user}} ->
        {:ok, user}

      {:error, error} ->
        {:error, error}
    end
  end

  def list_users, do: Repo.all(User)

  def list_bot_users() do
    try do
      from(u in User,
        where: u.is_bot == true,
        select: u.id
      )
      |> Repo.all()
    rescue
      _e ->
        []
    end
  end

  def get_preloaded_user(id) do
    Repo.get(User, id) |> Repo.preload([:coin_account])
  end

  def get_bet_amount_range(id) do
    user = get_preloaded_user(id)
    balance = user.coin_account.balance

    [0.1, 0.2, 0.5]
    |> Enum.with_index()
    |> Enum.map(fn {bet_percent, i} ->
      bet_amount = (balance * bet_percent) |> trunc
      bet_amount
    end)
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset_for_update(attrs)
    |> Repo.update()
  end

  def update_crendential(%Credential{} = credential, attrs \\ %{}) do
    credential
    |> Credential.changeset_for_update(attrs)
    |> Repo.update()
  end
end
