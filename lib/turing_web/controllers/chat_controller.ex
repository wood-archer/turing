defmodule TuringWeb.ChatController do
  use TuringWeb, :controller

  def index(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      TuringWeb.Live.Chat.Conversation,
      session: %{}
    )
  end
end
