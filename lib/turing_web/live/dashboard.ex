defmodule TuringWeb.Live.Dashboard do
  @moduledoc """
  Provides Dashboard live functions
  """

  require Logger

  use Phoenix.LiveView
  use Phoenix.HTML

  alias TuringWeb.DashboardView
  alias TuringWeb.Router.Helpers, as: Routes
  alias Turing.Chat.{Conversation, WaitingRoom, ConversationMember}
  alias Turing.{Accounts, Chat}
  alias Turing.Repo
  alias Ecto.Changeset

  def render(assigns) do
    DashboardView.render("show.html", assigns)
  end

  def mount(_params, %{"current_user" => current_user}, socket) do
    current_user = Repo.preload(current_user, [:conversations, :coin_account])

    {:ok,
     socket
     |> assign(current_user: current_user)
     |> assign_new_conversation_changeset()
     |> assign_contacts(current_user)
     |> assign(match_making_view: :intro_view)
     |> assign(matched: false)
     |> assign(conversation_id: nil)}
  end

  @doc """
  creates a conversation based on the payload that comes from the form
  (matched as `conversation form`).
  if its title is blank, build a title based on the usernames of conversation
  members.
  finally, reload the current user's `conversations` association, and re-assign
  it tot the socket so the template will be re-rendered.
  """
  def handle_event(
        "create_conversation",
        %{"conversation" => conversation_form},
        %{
          assigns: %{
            conversation_changeset: changeset,
            current_user: current_user,
            contacts: contacts
          }
        } = socket
      ) do
    conversation_form =
      Map.put(
        conversation_form,
        "title",
        if(conversation_form["title"] == "",
          do: build_title(changeset, contacts),
          else: conversation_form["title"]
        )
      )

    case Chat.create_conversation(conversation_form) do
      {:ok, _} ->
        {:noreply,
         assign(
           socket,
           :current_user,
           Repo.preload(current_user, :conversations, force: true)
         )}

      {:error, err} ->
        Logger.error(inspect(err))
    end
  end

  @doc """
  creates a conversation and move the user to a waiting room till a match is found.
  finally, reload the socket by adding conversation_id and move to new view.
  """
  def handle_event(
        "create_conversation",
        _phx_value,
        %{
          assigns: %{
            current_user: current_user
          }
        } = socket
      ) do
    conversation_id = WaitingRoom.pop()

    if conversation_id do
      join_conversation(current_user, conversation_id, socket)
    else
      create_conversation(current_user, socket)
    end
  end

  @doc """
    User waiting for a match in the waiting room, exits the room.
    TODO: delete conversation object from DB.
  """
  def handle_event(
        "exit_waiting_room",
        %{"conversation_id" => conversation_id},
        socket
      ) do
    _conversation_id = WaitingRoom.delete(%{"conversation_id" => conversation_id})

    socket =
      socket
      |> assign(match_making_view: :intro_view)
      |> assign(matched: false)
      |> assign(conversation_id: nil)

    {:noreply, socket}
  end

  def handle_event(
        "navigate_to_chat_view",
        %{"userid" => user_id, "conversationid" => conversation_id},
        socket
      ) do
    # TODO: publish to other chat party
    TuringWeb.Endpoint.broadcast!(
      "new_conversation_#{conversation_id}",
      "start_game",
      %{conversation_id: conversation_id}
    )

    {:noreply, socket}
  end

  @doc """
  adds a new member to the newly created conversation.
  "user-id" is passed from the link's "phx_value_user_id" attribute.
  finally, assign the changeset containing the new member's definition to
  the socket so the template can be re-rendered.
  """
  def handle_event(
        "add_member",
        %{"user-id" => new_member_id},
        %{assigns: %{conversation_changeset: changeset}} = socket
      ) do
    old_members = socket.assigns[:conversation_changeset].changes.conversation_members
    existing_ids = old_members |> Enum.map(& &1.changes.user_id)

    if new_member_id in existing_ids do
      {:noreply, socket}
    else
      new_members = [%{user_id: new_member_id} | old_members]

      new_changeset = Changeset.put_change(changeset, :conversation_members, new_members)

      {:noreply, assign(socket, :conversation_changeset, new_changeset)}
    end
  end

  @doc """
  removes a member from the newly created conversation and handle it similarly to
  when a member is added
  """
  def handle_event(
        "remove_member",
        %{"user-id" => removed_member_id},
        %{assigns: %{conversation_changeset: changeset}} = socket
      ) do
    old_members = socket.assigns[:conversation_changeset].changes.conversation_members
    new_members = old_members |> Enum.reject(&(&1.changes[:user_id] == removed_member_id))

    new_changeset = Changeset.put_change(changeset, :conversation_members, new_members)

    {:noreply, assign(socket, :conversation_changeset, new_changeset)}
  end

  def handle_info(%{event: "matched", payload: _new_message}, socket) do
    Process.sleep(3000)
    {:noreply, socket |> assign(:matched, true)}
  end

  def handle_info(
        %{event: "start_game", payload: payload},
        %{
          assigns: %{
            current_user: current_user
          }
        } = socket
      ) do
    {:stop,
     socket
     |> redirect(
       to:
         Routes.chat_path(
           TuringWeb.Endpoint,
           TuringWeb.Live.Chat.Conversation,
           payload.conversation_id,
           current_user.id
         )
     )}
  end

  defp build_title(changeset, contacts) do
    user_ids = Enum.map(changeset.changes.conversation_members, & &1.changes.user_id)

    contacts
    |> Enum.filter(&(&1.id in user_ids))
    |> Enum.map(& &1.first_name)
    |> Enum.join(", ")
  end

  # builds a changeset for the newly created conversation, initially
  # nesting a single conversation member record - the current user -
  # as the conversation's owner.
  defp assign_new_conversation_changeset(socket) do
    changeset =
      %Conversation{}
      |> Conversation.changeset(%{
        "conversation_members" => [
          %{
            owner: true,
            user_id: socket.assigns[:current_user].id
          }
        ]
      })

    assign(socket, :conversation_changeset, changeset)
  end

  # assign all users as the contact list
  defp assign_contacts(socket, _current_user) do
    users = Accounts.list_users()

    assign(socket, :contacts, users)
  end

  @doc """
    Create a conversation object with the current_user, change the view and assign it to the socket.
    Subscribe to wait till a match is found.
  """
  def create_conversation(current_user, socket) do
    conversation_form =
      Map.new([
        {"title", current_user.first_name},
        {"conversation_members", %{"0" => %{"user_id" => current_user.id}}}
      ])

    case Chat.create_conversation(conversation_form) do
      {:ok, conversation} ->
        WaitingRoom.push(%{"conversation_id" => conversation.id})
        TuringWeb.Endpoint.subscribe("new_conversation_#{conversation.id}")

        socket =
          socket
          |> assign(:conversation_id, conversation.id)
          |> assign(match_making_view: :match_making_avatars_view)

        {:noreply, socket}

      {:error, _err} ->
        {:noreply, socket}
    end
  end

  @doc """
    Match found! Join a conversation object by adding the current_user to the conversation member list.
    Broadcast mathching success to the other user.
    change the view and assign it to the socket.
  """
  def join_conversation(current_user, conversation_id, socket) do
    with %Conversation{} = conversation <- Repo.get(Conversation, conversation_id),
         {:ok, %ConversationMember{} = conversation_member} <-
           Chat.join_conversation(%{
             current_user: current_user,
             owner: false,
             conversation: conversation
           }) do
      TuringWeb.Endpoint.subscribe("new_conversation_#{conversation.id}")

      TuringWeb.Endpoint.broadcast!(
        "new_conversation_#{conversation_member.conversation_id}",
        "matched",
        %{}
      )

      socket =
        socket
        |> assign(:conversation_id, conversation_member.conversation_id)
        |> assign(match_making_view: :match_making_avatars_view)

      {:noreply, socket}
    else
      {:error, _} ->
        {:noreply, socket}
    end
  end
end
