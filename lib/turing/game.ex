defmodule Turing.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Turing.Repo
  alias Turing.Accounts.User
  alias Turing.Chat.Conversation
  alias Turing.Game.Bid

  @doc """
  Returns the list of bids.

  ## Examples

      iex> list_bids()
      [%Bid{}, ...]

  """
  def list_bids do
    Repo.all(Bid)
  end

  @doc """
  Gets a single bid.

  Raises `Ecto.NoResultsError` if the Bid does not exist.

  ## Examples

      iex> get_bid!(123)
      %Bid{}

      iex> get_bid!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bid!(id), do: Repo.get!(Bid, id)

  @doc """
  Creates a bid.

  ## Examples

      iex> create_bid(%{field: value})
      {:ok, %Bid{}}

      iex> create_bid(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bid(attrs \\ %{}) do
    %Bid{}
    |> Bid.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bid.

  ## Examples

      iex> update_bid(bid, %{field: new_value})
      {:ok, %Bid{}}

      iex> update_bid(bid, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bid(%Bid{} = bid, attrs) do
    bid
    |> Bid.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bid.

  ## Examples

      iex> delete_bid(bid)
      {:ok, %Bid{}}

      iex> delete_bid(bid)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bid(%Bid{} = bid) do
    Repo.delete(bid)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bid changes.

  ## Examples

      iex> change_bid(bid)
      %Ecto.Changeset{source: %Bid{}}

  """
  def change_bid(%Bid{} = bid) do
    Bid.changeset(bid, %{})
  end

  alias Turing.Game.CoinAccount

  @doc """
  Returns the list of coin_accounts.

  ## Examples

      iex> list_coin_accounts()
      [%Coin{}, ...]

  """
  def list_coin_accounts do
    Repo.all(CoinAccount)
  end

  @doc """
  Gets a single coin_account.

  Raises `Ecto.NoResultsError` if the CoinAccount does not exist.

  ## Examples

      iex> get_coin_account!(123)
      %Coin{}

      iex> get_coin_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coin_account!(id), do: Repo.get!(CoinAccount, id)

  @doc """
  Creates a coin_account.

  ## Examples

      iex> create_coin_account(%{field: value})
      {:ok, %CoinAccount{}}

      iex> create_coin_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coin_account(attrs \\ %{}) do
    %CoinAccount{}
    |> CoinAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a coin_account.

  ## Examples

      iex> update_coin_account(coin_account, %{field: new_value})
      {:ok, %CoinAccount{}}

      iex> update_coin_account(coin_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coin_account(%CoinAccount{} = coin_account, attrs) do
    coin_account
    |> CoinAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a coin_account.

  ## Examples

      iex> delete_coin_account(coin_account)
      {:ok, %CoinAccount{}}

      iex> delete_coin_account(coin_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coin_account(%CoinAccount{} = coin_account) do
    Repo.delete(coin_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coin_account changes.

  ## Examples

      iex> change_coin_account(coin_account)
      %Ecto.Changeset{source: %CoinAccount{}}

  """
  def change_coin_account(%CoinAccount{} = coin_account) do
    CoinAccount.changeset(coin_account, %{})
  end

  alias Turing.Game.CoinLog

  @doc """
  Returns the list of coin_logs.

  ## Examples

      iex> list_coin_logs()
      [%CoinLog{}, ...]

  """
  def list_coin_logs do
    Repo.all(CoinLog)
  end

  @doc """
  Gets a single coin_log.

  Raises `Ecto.NoResultsError` if the Coin log does not exist.

  ## Examples

      iex> get_coin_log!(123)
      %CoinLog{}

      iex> get_coin_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coin_log!(id), do: Repo.get!(CoinLog, id)

  @doc """
  Creates a coin_log.

  ## Examples

      iex> create_coin_log(%{field: value})
      {:ok, %CoinLog{}}

      iex> create_coin_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coin_log(attrs \\ %{}) do
    %CoinLog{}
    |> CoinLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a coin_log.

  ## Examples

      iex> update_coin_log(coin_log, %{field: new_value})
      {:ok, %CoinLog{}}

      iex> update_coin_log(coin_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coin_log(%CoinLog{} = coin_log, attrs) do
    coin_log
    |> CoinLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a coin_log.

  ## Examples

      iex> delete_coin_log(coin_log)
      {:ok, %CoinLog{}}

      iex> delete_coin_log(coin_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coin_log(%CoinLog{} = coin_log) do
    Repo.delete(coin_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coin_log changes.

  ## Examples

      iex> change_coin_log(coin_log)
      %Ecto.Changeset{source: %CoinLog{}}

  """
  def change_coin_log(%CoinLog{} = coin_log) do
    CoinLog.changeset(coin_log, %{})
  end

  @doc """
    Check can bid
    If requested amount is available in the coin_account balance
    return true
  """

  def check_can_bid?(%{"user_id" => user_id, "coins" => coins}) do
    with %User{} = _user <- Repo.get(User, user_id),
         %CoinAccount{} = coin_account <- Repo.get_by(CoinAccount, %{user_id: user_id}),
         true <- coin_account.balance >= coins do
      true
    else
      _ -> false
    end
  end

  @doc """
    Make a bid
    Withdraw the amount of coins from user's coin_account and update the balance
    Make an entry in the coin_logs for the user    
  """
  def make_bid(%{"conversation_id" => conversation_id, "user_id" => user_id} = params) do
    with %User{} = _user <- Repo.get(User, user_id),
         %Conversation{} = _conversation <- Repo.get(Conversation, conversation_id),
         %CoinAccount{} = coin_account <- Repo.get_by(CoinAccount, %{user_id: user_id}),
         {:ok, %Bid{} = bid} <- make_bid_transaction(params, coin_account) do
      {:ok, bid}
    else
      nil ->
        nil

      {error, changeset} ->
        {error, changeset}
    end
  end

  def make_bid_transaction(%{"coins" => coins, "user_id" => user_id} = params, coin_account) do
    new_balance = coin_account.balance - coins

    Multi.new()
    |> Multi.insert(:create_bid, Bid.changeset(%Bid{}, params))
    |> Multi.update(:update_balance, CoinAccount.changeset(coin_account, %{balance: new_balance}))
    |> Multi.insert(:add_coin_log, fn %{create_bid: bid} ->
      CoinLog.changeset(%CoinLog{}, %{
        user_id: user_id,
        coin_account_id: coin_account.id,
        bid_id: bid.id,
        coins: coins
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_bid: bid}} ->
        {:ok, bid}

      {:error, _, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  @doc """
    Based on bid result, settle the transaction
    Update coin_logs
    Update coin_account
  """
  def settle_bid(%{"bid_id" => bid_id, "result" => result} = _params) do
    with %Bid{} = bid <- Repo.get(Bid, bid_id),
         %User{} = user <- Repo.get(User, bid.user_id),
         %CoinAccount{} = coin_account <- Repo.get_by(CoinAccount, %{user_id: bid.user_id}),
         coins = settle_bid_value(%{"result" => result, "coins" => bid.coins}),
         {:ok, %Bid{} = bid} <-
           settle_bid_transaction(%{"result" => result, "coins" => coins}, bid, coin_account) do
      {:ok, bid}
    else
      nil ->
        nil

      {error, changeset} ->
        {error, changeset}
    end
  end

  def settle_bid_transaction(%{"result" => result, "coins" => coins} = _params, bid, coin_account) do
    new_balance = coin_account.balance + coins

    Multi.new()
    |> Multi.update(:update_bid, Bid.changeset(bid, %{result: result}))
    |> Multi.update(
      :update_coin_account,
      CoinAccount.changeset(coin_account, %{balance: new_balance})
    )
    |> Multi.insert(
      :add_coin_log,
      CoinLog.changeset(%CoinLog{}, %{
        user_id: coin_account.user_id,
        coin_account_id: coin_account.id,
        bid_id: bid.id,
        coins: coins,
        notes: "BID_SETTLEMENT"
      })
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{update_bid: bid}} ->
        {:ok, bid}

      {:error, _, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  def settle_bid_value(%{"result" => result, "coins" => coins}) do
    case result do
      "SUCCESS" -> coins * 2
      "FAILURE" -> 0
      "TIE" -> coins
    end
  end

  @doc """
    Resolve the conversation game.
    Update the respective bids with game result
  """
  def resolve_game(conversation_id) do
    with %Conversation{} = conversation <- Repo.get(Conversation, conversation_id),
         conversation = conversation |> Repo.preload([:bids, :users]),
         results = resolve_bids(conversation.bids, conversation.users) do
      Enum.map(results, fn result ->
        settle_bid(result)
      end)
    else
      nil ->
        nil

      {error, changeset} ->
        {error, changeset}
    end
  end

  @doc """
    Resolve all bids for a conversation
    #Need to improve current logic
  """
  def resolve_bids(bids, users) do
    result_map =
      Enum.reduce(bids, %{}, fn bid, result_map ->
        opponent = Enum.reject(users, fn user_id -> bid.user_id == user_id end) |> hd()
        result = if identify(opponent) == bid.guess, do: "SUCCESS", else: "FAILURE"
        bid_id = bid.id
        Map.merge(result_map, %{bid_id => result})
      end)

    [user_1_bid, user_2_bid] = bids

    if Map.get(result_map, user_1_bid.id) == "SUCCESS" &&
         Map.get(result_map, user_1_bid.id) == "SUCCESS" do
      [
        %{"bid_id" => user_1_bid.id, "result" => "TIE"},
        %{"bid_id" => user_2_bid.id, "result" => "TIE"}
      ]
    else
      [
        %{"bid_id" => user_1_bid.id, "result" => Map.get(result_map, user_1_bid.id)},
        %{"bid_id" => user_2_bid.id, "result" => Map.get(result_map, user_2_bid.id)}
      ]
    end
  end

  def identify(player) do
    if player.last_name, do: "HUMAN", else: "BOT"
  end

  def game_status_complete?(conversation_id) do
    with %Conversation{} = conversation <- Repo.get(Conversation, conversation_id),
         conversation = conversation |> Repo.preload([:bids, :users]),
         true <-
           length(conversation.bids) == length(conversation.users) &&
             length(conversation.bids) > 0 do
      true
    else
      _ ->
        false
    end
  end

  def get_my_bid(%{"conversation_id" => conversation_id, "user_id" => user_id}) do
    Repo.get_by(Bid, %{conversation_id: conversation_id, user_id: user_id})
  end
end
