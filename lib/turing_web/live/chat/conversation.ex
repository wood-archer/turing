defmodule TuringWeb.Live.Chat.Conversation do
  @moduledoc """
  Provides Conversation live functions
  """

  require Logger

  use Phoenix.LiveView
  use Phoenix.HTML

  alias TuringWeb.Router.Helpers, as: Routes
  alias Turing.{Accounts, Chat, Repo, Game}
  alias TuringWeb.Presence

  def mount(params, _assigns, socket) do
    user_id = params["user_id"]

    Presence.track(
      self(),
      "conversation_#{params["conversation_id"]}",
      user_id,
      %{}
    )

    TuringWeb.Endpoint.subscribe("user_#{user_id}")

    {:ok,
     socket
     |> assign(chat_right_pane_view: :navigate_to_choice_arrow)
     |> assign(play_view: :chat)
     |> assign(status: "BET")
     |> assign(user_id: params["user_id"])}
  end

  def render(assigns) do
    TuringWeb.Chat.ConversationView.render("index.html", assigns)
  end

  def handle_event("play_again", _params, socket) do
    {:stop, socket |> redirect(to: Routes.page_path(TuringWeb.Endpoint, :index))}
  end

  def handle_event(
        "bet_on_human",
        _params,
        %{
          assigns: %{
            user_id: user_id
          }
        } = socket
      ) do
    TuringWeb.Endpoint.broadcast_from!(
      self(),
      "user_#{user_id}",
      "play_view",
      %{bet_on: "Human", play_view: :bet_amount}
    )

    {:noreply,
     socket
     |> assign(play_view: :bet_amount)
     |> assign(bet_on: "Human")}
  end

  def handle_event(
        "bet_on_robot",
        _params,
        %{
          assigns: %{
            user_id: user_id
          }
        } = socket
      ) do
    TuringWeb.Endpoint.broadcast_from!(
      self(),
      "user_#{user_id}",
      "play_view",
      %{bet_on: "Robot", play_view: :bet_amount}
    )

    {:noreply,
     socket
     |> assign(play_view: :bet_amount)
     |> assign(bet_on: "Robot")}
  end

  def handle_event(
        "place_bet",
        %{"coins" => coins} = _params,
        %{
          assigns: %{
            conversation_id: conversation_id,
            user_id: user_id,
            bet_on: bet_on
          }
        } = socket
      ) do
    case Game.make_bid(%{
           "user_id" => user_id,
           "conversation_id" => conversation_id,
           "coins" => String.to_integer(coins),
           "guess" => String.upcase(bet_on)
         }) do
      {:ok, bid} ->
        TuringWeb.Endpoint.broadcast_from!(
          self(),
          "user_#{user_id}",
          "game_status",
          %{status: "WAITING"}
        )

        send(self(), {:resolve_game, %{bid_id: bid.id}})

        {:noreply, socket |> assign(status: "WAITING")}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("show_bid_choice", _params, socket) do
    {:noreply, socket |> assign(chat_right_pane_view: :bid_choice_view)}
  end

  def handle_event(
        "send_message",
        %{
          "message" => %{
            "content" => content
          }
        },
        %{
          assigns: %{
            conversation_id: conversation_id,
            user_id: user_id,
            user: user
          }
        } = socket
      ) do
    case Chat.create_message(%{
           conversation_id: conversation_id,
           user_id: user_id,
           content: content
         }) do
      {:ok, new_message} ->
        new_message = %{new_message | user: user}
        updated_messages = socket.assigns[:messages] ++ [new_message]

        TuringWeb.Endpoint.broadcast_from!(
          self(),
          "conversation_#{conversation_id}",
          "new_message",
          new_message
        )

        {:noreply, socket |> assign(:messages, updated_messages)}

      {:error, err} ->
        Logger.error(inspect(err))
    end
  end

  def handle_event(
        "navigate_to_chat_view",
        _params,
        %{
          assigns: %{
            user_id: user_id
          }
        } = socket
      ) do
    TuringWeb.Endpoint.broadcast_from!(
      self(),
      "user_#{user_id}",
      "play_view",
      %{bet_on: nil, play_view: :bet_amount}
    )

    {:noreply, socket |> assign(play_view: :chat)}
  end

  def handle_params(
        %{
          "conversation_id" => conversation_id,
          "user_id" => user_id
        },
        _uri,
        socket
      ) do
    TuringWeb.Endpoint.subscribe("conversation_#{conversation_id}")

    {:noreply,
     socket
     |> assign(:user_id, user_id)
     |> assign(:conversation_id, conversation_id)
     |> assign_records()}
  end

  def handle_info(%{event: "new_message", payload: new_message}, socket) do
    updated_messages = socket.assigns[:messages] ++ [new_message]

    {:noreply, socket |> assign(:messages, updated_messages)}
  end

  def handle_info(%{event: "play_view", payload: payload}, socket) do
    {:noreply,
     socket
     |> assign(play_view: payload.play_view)
     |> assign(bet_on: payload.bet_on)}
  end

  def handle_info(%{event: "game_status", payload: payload}, socket) do
    {:noreply, socket |> assign(status: payload.status)}
  end

  def handle_info(
        {:resolve_game, payload},
        %{assigns: %{conversation_id: conversation_id}} = socket
      ) do
    Process.sleep(3000)

    with {:ok, %Game.Bid{} = bid} <- Game.resolve_bid(conversation_id, payload.bid_id),
         game_status_complete = Game.game_status_complete?(conversation_id) do
      TuringWeb.Endpoint.broadcast_from!(
        self(),
        "conversation_#{conversation_id}",
        "bid_resolved",
        %{game_status_complete: game_status_complete, bid: bid}
      )

      result =
        case bid.result do
          "SUCCESS" -> :won
          "FAILURE" -> :lost
          "TIE" -> :tie
        end

      {:noreply, socket |> assign(play_view: result)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  def handle_info(
        %{event: "bid_resolved", payload: payload},
        %{
          assigns: %{
            user_id: user_id
          }
        } = socket
      ) do
    cond do
      payload.bid.user_id == user_id && payload.bid.result == "SUCCESS" ->
        {:noreply, socket |> assign(play_view: :won)}

      payload.bid.user_id == user_id && payload.bid.result == "FAILURE" ->
        {:noreply, socket |> assign(play_view: :lost)}

      payload.bid.user_id != user_id && payload.bid.result == "SUCCESS" &&
          !payload.game_status_complete ->
        {:noreply, socket |> assign(play_view: :lost)}

      payload.bid.user_id != user_id && payload.bid.result == "FAILURE" &&
          !payload.game_status_complete ->
        {:noreply, socket |> assign(chat_right_pane_view: :bid_choice_view)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_info(
        %{event: "presence_diff", payload: _payload},
        %{assigns: %{conversation: conversation}} = socket
      ) do
    users =
      "conversation_#{conversation.id}"
      |> Presence.list()

    {:noreply, assign(socket, users: users)}
  end

  defp assign_records(
         %{
           assigns: %{
             user_id: user_id,
             conversation_id: conversation_id
           }
         } = socket
       ) do
    user = Accounts.get_user!(user_id)

    conversation =
      conversation_id
      |> Chat.get_conversation!()
      |> Repo.preload(
        messages: [:user],
        conversation_members: [:user]
      )

    socket
    |> assign(:user, user)
    |> assign(:conversation, conversation)
    |> assign(:messages, conversation.messages)
  end
end
