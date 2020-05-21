defmodule MementoMori.Routine.Salutation do
  @moduledoc """
  MementoMori's Salutation routine.
  """

  alias Virtuoso.Impression

  def run(%Impression{debug: debug} = impression) when debug == true do
    %{text: run(), impression: impression}
  end

  def run(%Impression{} = impression) do
    run()
  end

  def run() do
    "Yo!"
  end
end
