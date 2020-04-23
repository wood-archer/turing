defmodule Turing.GameTest do
  use Turing.DataCase

  alias Turing.Game

  describe "bids" do
    alias Turing.Game.Bid

    @valid_attrs %{conversation: "some conversation", coins: 42, result: "some result", user: "some user"}
    @update_attrs %{conversation: "some updated conversation", coins: 43, result: "some updated result", user: "some updated user"}
    @invalid_attrs %{conversation: nil, coins: nil, result: nil, user: nil}

    def bid_fixture(attrs \\ %{}) do
      {:ok, bid} =
        attrs
        |> Enum.into(@valid_attrs)
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
      assert {:ok, %Bid{} = bid} = Game.create_bid(@valid_attrs)
      assert bid.conversation == "some conversation"
      assert bid.coins == 42
      assert bid.result == "some result"
      assert bid.user == "some user"
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_bid(@invalid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{} = bid} = Game.update_bid(bid, @update_attrs)
      assert bid.conversation == "some updated conversation"
      assert bid.coins == 43
      assert bid.result == "some updated result"
      assert bid.user == "some updated user"
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_bid(bid, @invalid_attrs)
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

    @valid_attrs %{balance: 42, user: "some user"}
    @update_attrs %{balance: 43, user: "some updated user"}
    @invalid_attrs %{balance: nil, user: nil}

    def coin_account_fixture(attrs \\ %{}) do
      {:ok, coin_account} =
        attrs
        |> Enum.into(@valid_attrs)
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
      assert {:ok, %CoinAccount{} = coin_account} = Game.create_coin_account(@valid_attrs)
      assert coin_account.balance == 42
      assert coin_account.user == "some user"
    end

    test "create_coin_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_coin_account(@invalid_attrs)
    end

    test "update_coin_account/2 with valid data updates the coin_account" do
      coin_account = coin_account_fixture()
      assert {:ok, %CoinAccount{} = coin_account} = Game.update_coin_account(coin_account, @update_attrs)
      assert coin_account.balance == 43
      assert coin_account.user == "some updated user"
    end

    test "update_coin_account/2 with invalid data returns error changeset" do
      coin_account = coin_account_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_coin_account(coin_account, @invalid_attrs)
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

    @valid_attrs %{bid: "some bid", coin: "some coin", user: "some user", value: 42}
    @update_attrs %{bid: "some updated bid", coin: "some updated coin", user: "some updated user", value: 43}
    @invalid_attrs %{bid: nil, coin: nil, user: nil, value: nil}

    def coin_log_fixture(attrs \\ %{}) do
      {:ok, coin_log} =
        attrs
        |> Enum.into(@valid_attrs)
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
      assert {:ok, %CoinLog{} = coin_log} = Game.create_coin_log(@valid_attrs)
      assert coin_log.bid == "some bid"
      assert coin_log.coin == "some coin"
      assert coin_log.user == "some user"
      assert coin_log.value == 42
    end

    test "create_coin_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_coin_log(@invalid_attrs)
    end

    test "update_coin_log/2 with valid data updates the coin_log" do
      coin_log = coin_log_fixture()
      assert {:ok, %CoinLog{} = coin_log} = Game.update_coin_log(coin_log, @update_attrs)
      assert coin_log.bid == "some updated bid"
      assert coin_log.coin == "some updated coin"
      assert coin_log.user == "some updated user"
      assert coin_log.value == 43
    end

    test "update_coin_log/2 with invalid data returns error changeset" do
      coin_log = coin_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_coin_log(coin_log, @invalid_attrs)
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
end
