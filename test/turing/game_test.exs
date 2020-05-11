defmodule Turing.GameTest do
  use Turing.DataCase

  alias Turing.Game
  alias Turing.Helper

  describe "bids" do
    alias Turing.Game.{Bid, CoinLog}
    alias Turing.{Accounts, Chat}

    @valid_user_attrs %{
      first_name: "some first_name",
      last_name: "some last_name"
    }
    @valid_bot_user_attrs %{
      first_name: "some first_name"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} = attrs |> Enum.into(@valid_user_attrs) |> Accounts.create_user()
      user
    end

    def user_setup_fixture(attrs \\ %{}) do
      {:ok, user} = attrs |> Enum.into(@valid_user_attrs) |> Accounts.setup_user()
      user
    end

    def bot_user_setup_fixture(attrs \\ %{}) do
      {:ok, user} = attrs |> Enum.into(@valid_bot_user_attrs) |> Accounts.setup_user()
      user
    end

    @valid_conversation_attrs %{title: "some title"}

    def conversation_fixture(attrs \\ %{}) do
      {:ok, conversation} =
        attrs
        |> Enum.into(@valid_conversation_attrs)
        |> Chat.create_conversation()

      conversation
    end

    @valid_bid_attrs %{
      coins: 2000,
      guess: "HUMAN"
    }
    @update_bid_attrs %{
      coins: 3500,
      guess: "BOT"
    }
    @invalid_bid_attrs %{conversation_id: nil, coins: nil, result: nil, user_id: nil}

    def bid_fixture(_attrs \\ %{}) do
      user = user_setup_fixture()
      conversation = conversation_fixture()
      attrs = Map.merge(@valid_bid_attrs, %{conversation_id: conversation.id, user_id: user.id})

      {:ok, bid} =
        attrs
        |> Enum.into(attrs)
        |> Game.create_bid()

      bid
    end

    test "list_bids/0 returns all bids" do
      bid = bid_fixture()
      assert Game.list_bids() == [bid]
    end

    test "get_bid!/1 returns the bid with given id" do
      bid = bid_fixture()
      assert Game.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid" do
      user = user_fixture()
      conversation = conversation_fixture()
      attrs = Map.merge(@valid_bid_attrs, %{conversation_id: conversation.id, user_id: user.id})
      assert {:ok, %Bid{} = bid} = Game.create_bid(attrs)
      assert bid.conversation_id == conversation.id
      assert bid.coins == 2000
      assert bid.user_id == user.id
      assert bid.guess == "HUMAN"
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_bid(@invalid_bid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{} = bid} = Game.update_bid(bid, @update_bid_attrs)
      assert bid.coins == 3500
      assert bid.guess == "BOT"
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_bid(bid, @invalid_bid_attrs)
      assert bid == Game.get_bid!(bid.id)
    end

    test "delete_bid/1 deletes the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{}} = Game.delete_bid(bid)
      assert_raise Ecto.NoResultsError, fn -> Game.get_bid!(bid.id) end
    end

    test "change_bid/1 returns a bid changeset" do
      bid = bid_fixture()
      assert %Ecto.Changeset{} = Game.change_bid(bid)
    end
  end

  describe "coin_accounts" do
    alias Turing.Game.CoinAccount

    @valid_coin_account_attrs %{balance: 42}
    @update_coin_account_attrs %{balance: 43}
    @invalid_coin_account_attrs %{balance: nil}

    def coin_account_fixture(_attrs \\ %{}) do
      user = user_fixture()
      attrs = Map.merge(@valid_coin_account_attrs, %{user_id: user.id})

      {:ok, coin_account} =
        attrs
        |> Enum.into(attrs)
        |> Game.create_coin_account()

      coin_account
    end

    test "list_coin_accounts/0 returns all coin_accounts" do
      coin_account = coin_account_fixture()
      assert Game.list_coin_accounts() == [coin_account]
    end

    test "get_coin_account!/1 returns the coin_account with given id" do
      coin_account = coin_account_fixture()
      assert Game.get_coin_account!(coin_account.id) == coin_account
    end

    test "create_coin_account/1 with valid data creates a coin_account" do
      user = user_fixture()
      attrs = Map.merge(@valid_coin_account_attrs, %{user_id: user.id})
      assert {:ok, %CoinAccount{} = coin_account} = Game.create_coin_account(attrs)
      assert coin_account.balance == 42
      assert coin_account.user_id == user.id
    end

    test "create_coin_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_coin_account(@invalid_coin_account_attrs)
    end

    test "update_coin_account/2 with valid data updates the coin_account" do
      coin_account = coin_account_fixture()

      assert {:ok, %CoinAccount{} = coin_account} =
               Game.update_coin_account(coin_account, @update_coin_account_attrs)

      assert coin_account.balance == 43
    end

    test "update_coin_account/2 with invalid data returns error changeset" do
      coin_account = coin_account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_coin_account(coin_account, @invalid_coin_account_attrs)

      assert coin_account == Game.get_coin_account!(coin_account.id)
    end

    test "delete_coin_account/1 deletes the coin_account" do
      coin_account = coin_account_fixture()
      assert {:ok, %CoinAccount{}} = Game.delete_coin_account(coin_account)
      assert_raise Ecto.NoResultsError, fn -> Game.get_coin_account!(coin_account.id) end
    end

    test "change_coin_account/1 returns a coin_account changeset" do
      coin_account = coin_account_fixture()
      assert %Ecto.Changeset{} = Game.change_coin_account(coin_account)
    end
  end

  describe "coin_logs" do
    alias Turing.Game.CoinLog

    @valid_coin_logs_attrs %{coins: 2000, notes: "BID_WITHDRAW"}
    @update_coin_logs_attrs %{
      coins: 4000,
      notes: "BID_SETTLEMENT"
    }
    @invalid_coin_logs_attrs %{coins: nil, notes: "BID_WITHDRAW"}

    def coin_log_fixture(_attrs \\ %{}) do
      bid = bid_fixture()
      bid = bid |> Repo.preload(user: [:coin_account])

      attrs =
        Map.merge(@valid_coin_logs_attrs, %{
          user_id: bid.user_id,
          bid_id: bid.id,
          coin_account_id: bid.user.coin_account.id
        })

      {:ok, coin_log} =
        attrs
        |> Enum.into(attrs)
        |> Game.create_coin_log()

      coin_log
    end

    test "list_coin_logs/0 returns all coin_logs" do
      coin_log = coin_log_fixture()
      assert Game.list_coin_logs() == [coin_log]
    end

    test "get_coin_log!/1 returns the coin_log with given id" do
      coin_log = coin_log_fixture()
      assert Game.get_coin_log!(coin_log.id) == coin_log
    end

    test "create_coin_log/1 with valid data creates a coin_log" do
      bid = bid_fixture()
      bid = bid |> Repo.preload(user: [:coin_account])

      attrs =
        Map.merge(@valid_coin_logs_attrs, %{
          user_id: bid.user_id,
          bid_id: bid.id,
          coin_account_id: bid.user.coin_account.id
        })

      assert {:ok, %CoinLog{} = coin_log} = Game.create_coin_log(attrs)
      assert coin_log.coins == 2000
      assert coin_log.notes == "BID_WITHDRAW"
    end

    test "create_coin_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_coin_log(@invalid_coin_logs_attrs)
    end

    test "update_coin_log/2 with valid data updates the coin_log" do
      coin_log = coin_log_fixture()

      assert {:ok, %CoinLog{} = coin_log} =
               Game.update_coin_log(coin_log, @update_coin_logs_attrs)

      assert coin_log.coins == 4000
      assert coin_log.notes == "BID_SETTLEMENT"
    end

    test "update_coin_log/2 with invalid data returns error changeset" do
      coin_log = coin_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_coin_log(coin_log, @invalid_coin_logs_attrs)

      assert coin_log == Game.get_coin_log!(coin_log.id)
    end

    test "delete_coin_log/1 deletes the coin_log" do
      coin_log = coin_log_fixture()
      assert {:ok, %CoinLog{}} = Game.delete_coin_log(coin_log)
      assert_raise Ecto.NoResultsError, fn -> Game.get_coin_log!(coin_log.id) end
    end

    test "change_coin_log/1 returns a coin_log changeset" do
      coin_log = coin_log_fixture()
      assert %Ecto.Changeset{} = Game.change_coin_log(coin_log)
    end
  end

  describe "game scenarios" do
    alias Turing.{Game.CoinLog, Game, Utils.Constants}
    alias Turing.{Chat}

    @default_balance Constants.default_signup_coin_account_balance()

    @missing_guess_bid_attrs %{
      coins: 2000
    }
    @valid_bid_attrs_human %{
      coins: 2000,
      guess: "HUMAN"
    }

    @valid_bid_attrs_bot %{
      coins: 2000,
      guess: "BOT"
    }

    @update_coin_account_zero_attrs %{
      balance: 0
    }

    test "place a bet with valid params" do
      user = user_setup_fixture()
      conversation = conversation_fixture()

      attrs =
        Map.merge(@valid_bid_attrs, %{conversation_id: conversation.id, user_id: user.id})
        |> Helper.build_string_map()

      {:ok, bid} = Game.make_bid(attrs)
      user = user |> Repo.preload([:coin_account])

      coin_log =
        Repo.get_by(CoinLog, %{
          user_id: user.id,
          coin_account_id: user.coin_account.id,
          bid_id: bid.id
        })

      assert bid.coins == attrs["coins"]
      assert bid.coins == coin_log.coins
    end

    test "place a bet with invalid params" do
      user = user_setup_fixture()
      conversation = conversation_fixture()

      attrs =
        Map.merge(@missing_guess_bid_attrs, %{conversation_id: conversation.id, user_id: user.id})
        |> Helper.build_string_map()

      assert {:error, %Ecto.Changeset{}} = Game.make_bid(attrs)
    end

    test "place a bet & resolve - rightly" do
      user_1 = user_setup_fixture()
      user_2 = user_setup_fixture()

      {:ok, conversation} = Chat.build_conversation([user_1.id, user_2.id])

      attrs =
        Map.merge(@valid_bid_attrs_human, %{conversation_id: conversation.id, user_id: user_1.id})
        |> Helper.build_string_map()

      {:ok, bid} = Game.make_bid(attrs)
      {:ok, bid} = Game.resolve_bid(conversation.id, bid.id)
      user_1 = user_1 |> Repo.preload([:coin_account])
      new_balance = user_1.coin_account.balance
      assert bid.coins == attrs["coins"]
      assert bid.guess == attrs["guess"]
      assert bid.result == "SUCCESS"
      assert @default_balance + bid.coins == new_balance
    end

    test "place a bet & resolve - rightly guessing BOT" do
      user_1 = user_setup_fixture()
      user_2 = bot_user_setup_fixture()

      {:ok, conversation} = Chat.build_conversation([user_1.id, user_2.id])

      attrs =
        Map.merge(@valid_bid_attrs_bot, %{conversation_id: conversation.id, user_id: user_1.id})
        |> Helper.build_string_map()

      {:ok, bid} = Game.make_bid(attrs)
      {:ok, bid} = Game.resolve_bid(conversation.id, bid.id)
      user_1 = user_1 |> Repo.preload([:coin_account])
      new_balance = user_1.coin_account.balance
      assert true == is_nil(user_2.last_name)
      if user_2.last_name, do: "HUMAN", else: "BOT"
      assert bid.coins == attrs["coins"]
      assert bid.guess == attrs["guess"]
      assert bid.result == "SUCCESS"
      assert @default_balance + bid.coins == new_balance
    end

    test "place a bet & resolve - wrongly" do
      user_1 = user_setup_fixture()
      user_2 = user_setup_fixture()
      {:ok, conversation} = Chat.build_conversation([user_1.id, user_2.id])

      attrs =
        Map.merge(@valid_bid_attrs_bot, %{conversation_id: conversation.id, user_id: user_1.id})
        |> Helper.build_string_map()

      {:ok, bid} = Game.make_bid(attrs)
      {:ok, bid} = Game.resolve_bid(conversation.id, bid.id)
      user_1 = user_1 |> Repo.preload([:coin_account])
      new_balance = user_1.coin_account.balance
      assert bid.coins == attrs["coins"]
      assert bid.guess == attrs["guess"]
      assert bid.result == "FAILURE"
      assert @default_balance - bid.coins == new_balance
    end

    test "reload coins if balance goes to zero" do
      user_1 = user_setup_fixture()
      user_1 = user_1 |> Repo.preload([:coin_account])

      {:ok, coin_account} =
        Game.update_coin_account(user_1.coin_account, @update_coin_account_zero_attrs)

      zero_balance = coin_account.balance
      {:ok, coin_account} = Game.reload_coin_account(user_1.coin_account)
      assert zero_balance == 0
      assert coin_account.balance == @default_balance
    end

    test "Do not reload coins if balance is not zero" do
      user_1 = user_setup_fixture()
      user_1 = user_1 |> Repo.preload([:coin_account])

      {:ok, coin_account_old} =
        Game.update_coin_account(user_1.coin_account, @update_coin_account_attrs)

      non_zero_balance = coin_account_old.balance
      {:ok, coin_account_new} = Game.reload_coin_account(coin_account_old)
      assert non_zero_balance == coin_account_new.balance
    end
  end
end
