defmodule TuringWeb.Live.Dashboard do
  require Logger

  use Phoenix.LiveView, container: {:div, [class: "row"]}
  use Phoenix.HTML

  alias TuringWeb.DashboardView
  alias Turing.Chat.Conversation
  alias Turing.{Accounts, Chat}
  alias Turing.Repo
  alias Ecto.Changeset

  def render(assigns) do
    DashboardView.render("show.html", assigns)
  end

  def mount(_params, %{"current_user" => current_user}, socket) do
    current_user = Repo.preload(current_user, :conversations)
    {:ok,
      socket
      |> assign(current_user: current_user)
      |> assign_new_conversation_changeset()
      |> assign_contacts(current_user)
    }
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
          )
        }

      {:error, err} ->
        Logger.error(inspect(err))

    end
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
    existing_ids = old_members |> Enum.map(&(&1.changes.user_id))

    if new_member_id not in existing_ids do
      new_members = [%{user_id: new_member_id} | old_members]

      new_changeset = Changeset.put_change(changeset, :conversation_members, new_members)

      {:noreply, assign(socket, :conversation_changeset, new_changeset)}

    else
      {:noreply, socket}

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

  defp build_title(changeset, contacts) do
    user_ids = Enum.map(changeset.changes.conversation_members, &(&1.changes.user_id))

    contacts
    |> Enum.filter(&(&1.id in user_ids))
    |> Enum.map(&(&1.first_name))
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
end
