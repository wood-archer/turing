defmodule TuringWeb.Live.Dashboard do
  @moduledoc """
  Provides Dashboard live functions
  """

  use Phoenix.LiveView
  use Phoenix.HTML

  alias TuringWeb.{DashboardView, Presence}
  alias TuringWeb.Router.Helpers, as: Routes
  alias Turing.{Game}
  alias Turing.Repo

  def render(assigns) do
    DashboardView.render("show.html", assigns)
  end

  def mount(_params, %{"current_user" => current_user}, socket) do
    current_user = Repo.preload(current_user, [:conversations, :coin_account])
    Game.reload_coin_account(current_user.coin_account)
    TuringWeb.Endpoint.subscribe("user_#{current_user.id}")

    {:ok,
     socket
     |> assign(current_user: current_user)
     |> assign(match_making_view: :intro_view)
     |> assign(matched: false)
     |> assign(conversation_id: nil)}
  end

  def handle_event(
        "enter_waiting_room",
        _params,
        %{
          assigns: %{
            current_user: current_user
          }
        } = socket
      ) do
    Presence.track(
      self(),
      "waiting_room",
      current_user.id,
      %{}
    )

    {:noreply, socket |> assign(match_making_view: :match_making_avatars_view)}
  end

  def handle_event(
        "leave_waiting_room",
        _params,
        %{
          assigns: %{
            current_user: current_user
          }
        } = socket
      ) do
    Presence.untrack(
      self(),
      "waiting_room",
      current_user.id
    )

    {:noreply, socket |> assign(match_making_view: :intro_view)}
  end

  def handle_event(
        "view_leaderboard",
        _params,
        socket
      ) do
    {:stop,
     socket
     |> redirect(
       to:
         Routes.leaderboard_path(
           TuringWeb.Endpoint,
           TuringWeb.Live.Leaderboard
         )
     )}
  end

  def handle_info(
        %{event: "matched", payload: payload},
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
end
