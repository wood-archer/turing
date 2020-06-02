defmodule TuringWeb.Chat.WaitingRoom do
  use GenServer

  alias TuringWeb.Presence
  alias Turing.{Chat, Accounts}
  alias Turing.Utils.Constants
  alias Turing.Bot.{Supervisor}

  @number_of_bot_users Constants.number_of_bot_users()

  def start_link(_) do
    GenServer.start_link(__MODULE__, Map.new(), name: __MODULE__)
  end

  def init(_state) do
    state =
      Accounts.list_bot_users()
      |> Enum.take_random(@number_of_bot_users)
      |> Enum.reduce(%{}, fn user_id, acc ->
        pid = create_bot(user_id)
        Map.put(acc, user_id, %{pid: pid, status: "ready"})
      end)

    Process.send_after(self(), :match, 5_000)
    {:ok, state}
  end

  def create_bot(user_id) do
    {:ok, pid} = Supervisor.start_child(user_id)
    pid
  end

  def handle_info(:match, state) do
    state =
      with users = Presence.list("waiting_room") |> Map.keys(),
           {true, match_type, players} <- Chat.match(users, get_ready_bots(state)),
           {:ok, %Chat.Conversation{} = conversation} <- Chat.build_conversation(players) do
        manage_players(players, conversation.id, match_type, state)
      else
        false ->
          state
      end

    Process.send_after(self(), :match, 5_000)
    {:noreply, state}
  end

  def handle_call({:lookup, user_id}, _from, state) do
    {:reply, Map.fetch(state, user_id), state}
  end

  def handle_call(:get_all, _, state) do
    {:reply, state, state}
  end

  def handle_call({:add_entry, user_id}, _, state) do
    new_state = Map.put(state, :user_id, user_id)
    {:reply, user_id, new_state}
  end

  def handle_call({:remove_entry, user_id}, _, state) do
    new_state = Map.delete(state, user_id)
    {:reply, user_id, new_state}
  end

  def handle_cast({:update_entry, user_id, status}, state) do
    user = Map.get(state, user_id) |> Map.drop([:conversation_id])
    user = Map.put(user, :status, status)
    new_state = Map.put(state, user_id, user)
    {:noreply, new_state}
  end

  def enter(%{"user_id" => user_id}) do
    GenServer.call(__MODULE__, {:add_entry, user_id})
  end

  def exit(%{"user_id" => user_id}) do
    GenServer.call(__MODULE__, {:remove_entry, user_id})
  end

  def fetch(%{"user_id" => user_id}) do
    GenServer.call(__MODULE__, {:lookup, user_id})
  end

  def list() do
    GenServer.call(__MODULE__, :get_all)
  end

  def update_bot_status(user_id, status) do
    GenServer.cast(__MODULE__, {:update_entry, user_id, status})
  end

  def get_ready_bots(state) do
    for {key, %{status: status}} <- state do
      if status == "ready", do: key
    end
    |> Enum.reject(&is_nil/1)
  end

  def manage_players([human, bot] = players, conversation_id, match_type, state)
      when match_type == "mixed" do
    Enum.map(players, fn player ->
      TuringWeb.Endpoint.broadcast_from!(
        self(),
        "user_#{player}",
        "matched",
        %{conversation_id: conversation_id}
      )
    end)

    Presence.untrack(
      self(),
      "waiting_room",
      human
    )

    bot_user = state |> Map.get(bot)
    bot_user = Map.put(bot_user, :status, "playing")
    Map.put(state, bot, bot_user)
  end

  def manage_players(players, conversation_id, _match_type, state) do
    Enum.map(players, fn player ->
      TuringWeb.Endpoint.broadcast_from!(
        self(),
        "user_#{player}",
        "matched",
        %{conversation_id: conversation_id}
      )

      Presence.untrack(
        self(),
        "waiting_room",
        player
      )
    end)

    state
  end
end
