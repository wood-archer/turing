defmodule Turing.Bot.Player do
  use GenServer
  alias Phoenix.Socket.{Broadcast}
  alias Turing.{Accounts, Chat}
  require Logger

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: user_id |> String.to_atom())
  end

  def init(user_id) do
    Logger.info("state #{inspect(user_id)}")

    # state = %{user_id: user_id, bot_responder: Virtuoso.Admin.Dashboard.list_bots() |> Map.keys() |> Enum.random() |> Atom.to_string}
    state = %{user_id: user_id, bot_responder: "MementoMori"}
    Logger.info("state #{inspect(state)}")
    TuringWeb.Endpoint.subscribe("user_#{user_id}")

    {:ok, state}
  end

  def handle_info(broadcast = %Broadcast{}, state) do
    Logger.info("broadcast #{inspect(broadcast)}")
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

  # @doc """
  #     Terminate a bot once conversation is over
  # """
  # @spec terminate(user_id()) :: :ok
  # def terminate(user_id) do
  #     GenServer.call(pid(sender_id), :terminate)
  # end

  def user_events(broadcast, state) do
    case broadcast.event do
      "matched" ->
        conversation_id = broadcast.payload.conversation_id
        TuringWeb.Endpoint.subscribe("conversation_#{conversation_id}")
        Map.put(state, :conversation_id, conversation_id)

      _ ->
        state
    end
  end

  def conversation_events(broadcast, state) do
    Logger.info("conversation_events broadcast #{inspect(broadcast)}")
    Logger.info("state #{inspect(state)}")

    case broadcast.event do
      "new_message" ->
        broadcast.payload.content
        |> build_virtuoso_param(state)
        |> Virtuoso.handle()
        |> send_message(state)

      "bid_resolved" ->
        state

      _ ->
        state
    end
  end

  def get_my_pid() do
  end

  def build_virtuoso_param(new_message, state) do
    Logger.info("new_message #{inspect(new_message)}")
    Logger.info("state #{inspect(state)}")

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
    Logger.info("message #{inspect(message)}")
    content = message["message"]["text"]
    Logger.info("content #{inspect(content)}")

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

      {:error, err} ->
        Logger.error("error #{inspect(err)}")
        state
    end
  end
end
