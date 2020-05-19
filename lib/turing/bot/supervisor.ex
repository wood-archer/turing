defmodule Turing.Bot.Supervisor do
    @moduledoc """
        Supervisor for conversation processes
    """
    use DynamicSupervisor
    alias Turing.Bot.Player
    
    def start_link(_arg) do
      DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
  
    @impl true
    def init(_init_arg) do
      DynamicSupervisor.init(strategy: :one_for_one)
    end
  
    def start_child(child_name) do
      DynamicSupervisor.start_child(
        __MODULE__,
        %{id: Player, start: { Player, :start_link,  [child_name]}, restart: :transient})
    end
  end
  