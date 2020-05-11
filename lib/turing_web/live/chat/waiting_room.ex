defmodule Turing.Chat.WaitingRoom do
  use GenServer
  alias Phoenix.Socket.{Broadcast}

  alias TuringWeb.Presence
  alias Turing.Chat

  def start_link(_) do
    GenServer.start_link(__MODULE__, MapSet.new(), name: Conversations)
  end

  def init(state) do
    TuringWeb.Endpoint.subscribe("waiting_room")
    {:ok, state}
  end

  def handle_info(broadcast = %Broadcast{}, state) do
    with event when event in ["presence_diff"] <-
           broadcast.event,
         true <- broadcast.topic == "waiting_room",
         true <- map_size(broadcast.payload.joins) > 0,
         users = Presence.list("waiting_room") |> Map.keys(),
         true <- Chat.can_match?(users),
         players = Enum.take_random(users, 2),
         {:ok, %Chat.Conversation{} = conversation} <- Chat.build_conversation(players) do
      manage_players(players, conversation)
      {:noreply, state}
    else
      _ ->
        {:noreply, state}
    end
  end

  def manage_players(players, conversation_id) do
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
  end
end
