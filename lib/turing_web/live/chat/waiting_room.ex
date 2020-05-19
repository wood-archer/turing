defmodule TuringWeb.Chat.WaitingRoom do
  use GenServer
  alias Phoenix.Socket.{Broadcast}
  require Logger
  alias TuringWeb.Presence
  alias Turing.{Chat, Accounts}
  alias Turing.Bot.{Supervisor}

  def start_link(_) do
    GenServer.start_link(__MODULE__, Map.new(), name: __MODULE__)
  end

  def init(state) do
    TuringWeb.Endpoint.subscribe("waiting_room")
    state = Accounts.list_bot_users() 
    |> Enum.take_random(2) 
    |> Enum.reduce(%{}, fn (user_id, acc) ->
      pid = create_bot(user_id)
      Map.put(acc, user_id, %{pid: pid, status: "ready"})
    end)
    {:ok, state}
  end

  def handle_cast({:create, user_id}, state) do
    pid = create_bot(user_id)
    state = Map.put(state, user_id, %{pid: pid, status: "ready"})
    {:noreply, state}
  end

  def create_bot(user_id) do
    {:ok, pid} = Supervisor.start_child(user_id)
    pid
  end

  def handle_info(broadcast = %Broadcast{}, state) do
    Logger.info"broadcast.payload #{inspect broadcast.payload}"
    with event when event in ["presence_diff"] <-
          broadcast.event,
          true <- broadcast.topic == "waiting_room",
          true <- map_size(broadcast.payload.joins) > 0,
          users = Presence.list("waiting_room") |> Map.keys(),
          {match_type, players} = Chat.match(users,get_ready_bots(state)),
          {:ok, %Chat.Conversation{} = conversation} <- Chat.build_conversation(players) do
            state = manage_players(players, conversation.id, match_type, state)
            {:noreply, state}
    else
      _ ->
        {:noreply, state}
    end
  end  

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_call(:get_all, _, state) do
      {:reply, state, state}
  end

  def handle_call({:add_entry, user_id}, _,state) do
      new_state = MapSet.put(state, user_id)
      {:reply, user_id, new_state}
  end

  def handle_call({:remove_entry, user_id}, _,state) do
      new_state = MapSet.delete(state, user_id)
      {:reply, user_id, new_state}
  end

  def handle_call({:update_entry, user_id, status}, state) do
      user = Map.get(state, user_id)
      user = Map.put(user, :status, status)
      new_state = Map.put(state, user_id, user)
      {:reply, user_id, new_state}
  end

  def enter(%{"user_id" => user_id}) do
      GenServer.call __MODULE__,{:add_entry, user_id}
  end

  def exit(%{"user_id" => user_id}) do
      GenServer.call __MODULE__,{:remove_entry, user_id}
  end

  def list() do
      GenServer.call __MODULE__,:get_all
  end

  def create_new_bot(user_id) do
    GenServer.cast __MODULE__,{:create, user_id}
  end

  def create_new_bots() do
    Accounts.list_bot_users() |> Enum.take_random(2) |> Enum.map(&create_new_bot/1)
  end

  def update_bot_status(user_id, status) do
    GenServer.call __MODULE__,{:update_entry, user_id, status}
  end

  def get_ready_bots(state) do
    for {key, %{status: status}} <- state do
      if status == "ready", do: key
    end |> Enum.reject(&is_nil/1)
  end

  def manage_players([human, bot] = players, conversation_id, match_type, state) when match_type == "mixed" do
    
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
    user = Map.get(state, bot)
    user = Map.put(user, :status, "playing")
    Map.put(state, bot, user)
  end

  def manage_players(players, conversation_id, match_type, state) do
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
