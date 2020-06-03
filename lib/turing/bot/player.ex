defmodule Turing.Bot.Player do
  use GenServer
  alias Phoenix.Socket.{Broadcast}
  alias Turing.{Accounts, Chat, Game}
  alias TuringWeb.Chat.WaitingRoom
  @registry :bots_registry
  require Logger

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: get_pid(user_id))
  end

  def init(user_id) do
    bot_responder =
      Virtuoso.Admin.Dashboard.list_bots()
      |> Enum.random()
      |> Map.get(:botname)
      |> Atom.to_string()

    state = %{user_id: user_id, bot_responder: bot_responder}
    TuringWeb.Endpoint.subscribe("user_#{user_id}")
    {:ok, state}
  end

  def handle_cast(:clean_up, %{user_id: user_id, conversation_id: conversation_id} = state) do
    WaitingRoom.update_bot_status(user_id, "ready")
    TuringWeb.Endpoint.unsubscribe("conversation_#{conversation_id}")
    new_state = Map.drop(state, [:conversation_id])
    {:noreply, new_state}
  end

  def handle_info(broadcast = %Broadcast{}, state) do
    user_event_clause = "user_#{state.user_id}"

    conversation_event_clause =
      if Map.has_key?(state, :conversation_id), do: "conversation_#{state.conversation_id}"

    state =
      cond do
        broadcast.topic == user_event_clause ->
          user_events(broadcast, state)

        broadcast.topic == conversation_event_clause ->
          conversation_events(broadcast, state)

        true ->
          state
      end

    {:noreply, state}
  end

  def handle_info(:make_bid, state) do
    state =
      if Map.has_key?(state, :conversation_id) do
        make_bid(state)
      else
        state
      end

    {:noreply, state}
  end

  def handle_info({:send_message, data}, state) do
    case String.contains?(data[:message], "ParlAI") do
      true ->
        {:noreply, state}

      false ->
        message = %{"message" => %{"text" => data[:message]}}
        send_message(message, data)
        {:noreply, state}
    end
  end

  def handle_info({:resolve_game, payload}, %{conversation_id: conversation_id} = state) do
    with {:ok, %Game.Bid{} = bid} <- Game.resolve_bid(conversation_id, payload.bid_id),
         game_status_complete = Game.game_status_complete?(conversation_id) do
      TuringWeb.Endpoint.broadcast_from!(
        self(),
        "conversation_#{conversation_id}",
        "bid_resolved",
        %{game_status_complete: game_status_complete, bid: bid}
      )

      clean_up_bot(state)
      {:noreply, state}
    else
      _ ->
        {:noreply, state}
    end
  end

  def user_events(broadcast, state) do
    case broadcast.event do
      "matched" ->
        conversation_id = broadcast.payload.conversation_id
        TuringWeb.Endpoint.subscribe("conversation_#{conversation_id}")
        Process.send_after(self(), :make_bid, 30_000)
        state = Map.put(state, :conversation_id, conversation_id)
        state = Map.put(state, :sender, self())

        {:ok, parlai_pid} = Parlai.Client.start_link(state)

        Parlai.Client.send_message(
          parlai_pid,
          Jason.encode!(%{text: "start"}),
          state
        )

        Parlai.Client.send_message(
          parlai_pid,
          Jason.encode!(%{text: "begin"}),
          state
        )

        state = Map.put(state, :parlai_pid, parlai_pid)
        state

      _ ->
        state
    end
  end

  def conversation_events(broadcast, state) do
    case broadcast.event do
      "new_message" ->
        parlai_pid = state[:parlai_pid]

        Parlai.Client.send_message(
          parlai_pid,
          Jason.encode!(%{text: broadcast.payload.content}),
          state
        )

      # broadcast.payload.content
      # |> build_virtuoso_param(state)
      # |> Virtuoso.handle()
      # |> send_message(state)

      "bid_resolved" ->
        if broadcast.payload.bid.result == "SUCCESS" do
          clean_up_bot(state)
        else
          make_bid(state)
        end

      _ ->
        state
    end
  end

  def build_virtuoso_param(new_message, state) do
    %{
      "object" => "",
      "entry" => %{
        "messaging" => %{
          "timestamp" => DateTime.utc_now() |> DateTime.to_unix(),
          "sender" => %{
            "id" => self()
          },
          "recipient" => %{
            "id" => state.bot_responder
          },
          "message" => %{
            "text" => new_message
          }
        }
      }
    }
  end

  def send_message(message, %{conversation_id: conversation_id, user_id: user_id} = state) do
    content = message["message"]["text"]
    Process.sleep(3000)

    case Chat.create_message(%{
           conversation_id: conversation_id,
           user_id: user_id,
           content: content
         }) do
      {:ok, new_message} ->
        new_message = %{new_message | user: Accounts.get_user!(user_id)}

        TuringWeb.Endpoint.broadcast_from!(
          self(),
          "conversation_#{conversation_id}",
          "new_message",
          new_message
        )

        state

      {:error, _err} ->
        state
    end
  end

  def make_bid(%{user_id: user_id, conversation_id: conversation_id} = state) do
    user = Accounts.get_preloaded_user(user_id)
    coins = Enum.random(1..user.coin_account.balance)
    guess = Enum.random(["BOT", "HUMAN"])

    case Game.make_bid(%{
           "user_id" => user_id,
           "conversation_id" => conversation_id,
           "coins" => coins,
           "guess" => guess
         }) do
      {:ok, bid} ->
        send(self(), {:resolve_game, %{bid_id: bid.id}})

      {:error, error} ->
        {:error, error}
    end

    state
  end

  defp get_pid(sender_id) do
    {:via, Registry, {@registry, sender_id}}
  end

  def clean_up_bot(state) do
    GenServer.cast(get_pid(state.user_id), :clean_up)
    state
  end
end
