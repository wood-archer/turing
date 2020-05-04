defmodule Turing.Chat.WaitingRoom do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, MapSet.new(), name: Conversations)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_all, _, state) do
    {:reply, state, state}
  end

  def handle_call({:add_entry, conversation_id}, _, state) do
    new_state = MapSet.put(state, conversation_id)
    {:reply, conversation_id, new_state}
  end

  def handle_call({:remove_entry, conversation_id}, _, state) do
    new_state = MapSet.delete(state, conversation_id)
    {:reply, conversation_id, new_state}
  end

  def handle_call(:pop_entry, _, state) do
    if MapSet.size(state) > 0 do
      conversation_id = MapSet.to_list(state) |> hd()
      new_state = MapSet.delete(state, conversation_id)
      {:reply, conversation_id, new_state}
    else
      {:reply, nil, state}
    end
  end

  def push(%{"conversation_id" => conversation_id}) do
    GenServer.call(Conversations, {:add_entry, conversation_id})
  end

  def delete(%{"conversation_id" => conversation_id}) do
    GenServer.call(Conversations, {:remove_entry, conversation_id})
  end

  def pop() do
    GenServer.call(Conversations, :pop_entry)
  end

  def list() do
    GenServer.call(Conversations, :get_all)
  end
end
