defmodule TuringWeb.Live.Index do
  use Phoenix.LiveView

  alias Turing.Chat
  alias Turing.Chat.Message

  def mount(_session, socket) do
    if connected?(socket), do: Chat.subscribe()
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    TuringWeb.ChatView.render("index.html", assigns)
  end

  def fetch(socket, username \\ nil) do
    assign(socket, %{
      username: username,
      messages: Chat.list_messages(),
      changeset: Chat.change_message(%Message{username: username})
    })
  end

  def handle_event("validate", %{"message"=> params}, socket) do
    changeset =
      %Message{}
      |> Chat.change_message(params)
      |> Map.put(:action, :insert)


    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("send_message", %{"message"=> params}, socket) do
    case Chat.create_message(params) do
      {:ok, message} ->
        {:noreply, fetch(socket, message.username)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

    end
  end

  def handle_info({Chat, [:message, _event_type], _message}, socket) do
    {:noreply, fetch(socket, get_username(socket))}
  end

  defp get_username(socket) do
    socket.assigns
    |> Map.get(:username)
  end
end
