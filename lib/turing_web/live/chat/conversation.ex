defmodule TuringWeb.Live.Chat.Conversation do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Turing.{Accounts, Chat, Repo}

  def mount(_assigns, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <%= @conversation.title %>
    </div>
    <hr />

    <div>
      <%= for message <- @messages do %>
        <div>
          <b><%= message.user.first_name %></b>: <%= message.content %>
        </div>
      <% end %>
    </div>

    <hr />

    <div>
      <%= f = form_for :message, "#", [phx_submit: "send_message"] %>
        <%= text_input f, :content %>
        <%= submit "Send" %>
      </form>
    </div>
    """
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

        TuringWeb.Endpoint.broadcast_from!(
          self(),
          "conversation_#{conversation_id}",
          "new_message",
          new_message
        )

      {:error, _} ->
        {:noreply, socket}

    end

    {:noreply, socket}
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
      |> assign_records()
    }
  end

  def handle_info(%{event: "new_message", payload: new_message}, socket) do
    updated_messages = socket.assigns[:messages] ++ [new_message]

    {:noreply, socket |> assign(:messages, updated_messages)}
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
