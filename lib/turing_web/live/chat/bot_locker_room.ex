defmodule Turing.Chat.BotLockerRoom do
    use GenServer
    alias Turing.Accounts
    def start_link(_) do
        GenServer.start_link(__MODULE__, MapSet.new(), name: __MODULE__)
    end
  
    def init(state) do
        state = Accounts.list_bot_users()
        {:ok, state}
    end

    def handle_call({:lookup, name}, _from, names) do
        {:reply, Map.fetch(names, name), names}
    end

    def handle_call(:get_all, _, state) do
        {:reply, state, state}
    end

    def handle_call({:add_entry, user_id}, _,state) do
        new_state = MapSet.put(state, user_id)
        {:reply, user_id, new_state}
    end

    def handle_call({:remove_entry, user_id}, _,state) do
        new_state = MapSet.delete(state, user_id)
        {:reply, user_id, new_state}
    end

    def enter(%{"user_id" => user_id}) do
        GenServer.call __MODULE__,{:add_entry, user_id}
    end

    def exit(%{"user_id" => user_id}) do
        GenServer.call __MODULE__,{:remove_entry, user_id}
    end

    def list() do
        GenServer.call __MODULE__,:get_all
    end    
  
  end
  