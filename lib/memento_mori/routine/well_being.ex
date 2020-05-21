defmodule MementoMori.Routine.WellBeing do
  @moduledoc """
  MementoMori's WellBeing routine.
  """

  alias Virtuoso.Impression

  def run(%Impression{debug: debug} = impression) when debug == true do
    %{text: run(), impression: impression}
  end

  def run(%Impression{} = impression) do
    run()
  end

  def run() do
    "I'm good. How about you?"
  end
end
