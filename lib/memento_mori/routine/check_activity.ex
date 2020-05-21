defmodule MementoMori.Routine.CheckActivity do
  @moduledoc """
  MementoMori's CheckActivity routine.
  """

  alias Virtuoso.Impression

  def run(%Impression{debug: debug} = impression) when debug == true do
    %{text: run(), impression: impression}
  end

  def run(%Impression{} = impression) do
    run()
  end

  def run() do
    "Nothing much, just lazing around. What are you up to?"
  end
end
