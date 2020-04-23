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
    Presence.track(
      self(),
      "conversation_#{params["conversation_id"]}",
      params["user_id"],
      %{}
    )

    {:ok, socket
    |> assign(chat_right_pane_view: :navigate_to_choice_arrow)
    |> assign(play_view: :chat)
    |> assign(status: "BET")
    |> assign(user_id: params["user_id"])
  }
  end

  def render(assigns) do
    TuringWeb.Chat.ConversationView.render("index.html", assigns)
  end

  def handle_event("play_again", _params, socket) do
    {:stop, socket |> redirect(to: Routes.page_path(TuringWeb.Endpoint, :index))}
  end
  def handle_event("bet_on_human", _params, socket) do
    {:noreply,
     socket
     |> assign(play_view: :bet_amount)
     |> assign(bet_on: "Human")
    }
  end

  def handle_event("bet_on_robot", _params, socket) do
    {:noreply,
     socket
     |> assign(play_view: :bet_amount)
     |> assign(bet_on: "Robot")
    }
  end

  def handle_event("place_bet", %{"coins" => coins}= _params, %{
        assigns: %{
          conversation_id: conversation_id,
          user_id: user_id,
          bet_on: bet_on
        }
      } = socket) do
    case Game.make_bid(%{"user_id" => user_id, "conversation_id" => conversation_id, "coins" => String.to_integer(coins), "guess" => String.upcase(bet_on)}) do
      {:ok, _bid} ->
            payload = %{user_id: user_id}
            TuringWeb.Endpoint.broadcast_from!(
              self(),
              "conversation_#{conversation_id}",
              "bid_placed",
              payload
            )
            {:noreply, socket |> assign(status: "WAITING")}    
        _ -> {:noreply, socket}
    end
  end

  def handle_event("show_result",_params, %{
        assigns: %{
          conversation_id: conversation_id,
          user_id: user_id
        }
      } = socket) do
      bid = Game.get_my_bid(%{"conversation_id" => conversation_id, "user_id" => user_id})
      result = case bid.result do
        "SUCCESS" -> :won
        "FAILURE" -> :lost
        "TIE" -> :tie
      end
      {:noreply, socket |> assign(play_view: result)}
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
        } = _socket
      ) do
    case Chat.create_message(%{
           conversation_id: conversation_id,
           user_id: user_id,
           content: content
         }) do
      {:ok, new_message} ->
        new_message = %{new_message | user: user}

        TuringWeb.Endpoint.broadcast_from!(
          self(),
          "conversation_#{conversation_id}",
          "new_message",
          new_message
        )

      {:error, err} ->
        Logger.error(inspect(err))
    end
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

  def handle_info(%{event: "bid_placed", payload: payload}, %{ assigns: %{conversation_id: conversation_id}} = socket) do
    case Game.game_status_complete?(conversation_id) do
      true -> TuringWeb.Endpoint.broadcast_from!(
                self(),
                "conversation_#{conversation_id}",
                "resolve_game",
                payload
              )
              {:noreply, socket}    
      false -> {:noreply, socket |> assign(chat_right_pane_view: :bid_choice_view)}    
    end
  end  

  def handle_info(%{event: "resolve_game", payload: payload}, %{ assigns: %{conversation_id: conversation_id}} = socket) do
    Game.resolve_game(conversation_id)
    TuringWeb.Endpoint.broadcast!(
                "conversation_#{conversation_id}",
                "resolved_game",
                payload
              )
    {:noreply, socket}
  end  

  def handle_info(%{event: "resolved_game", payload: _payload}, socket) do
    {:noreply, socket |> assign(status: "SHOW_RESULT")}    
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
