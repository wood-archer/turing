defmodule Parlai.Client do
  use WebSockex
  require Logger

  def start_link(state) do
    WebSockex.start_link(
      "ws://3.86.221.116:10001/websocket",
      __MODULE__,
      state,
      []
    )
  end

  @spec send_message(pid, String.t(), Map.t()) :: :ok
  def send_message(client, message, state) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
    state
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    Logger.info("Received Message: #{msg}")
    sender = state[:sender]
    msg = Poison.decode!(msg)["text"]
    state = Map.put(state, :message, msg)
    send(sender, {:send_message, state})
    {:ok, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end
end
