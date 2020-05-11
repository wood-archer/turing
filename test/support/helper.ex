defmodule Turing.Helper do
  def build_atomic_map(input_map) do
    for {key, val} <- input_map, into: %{}, do: {String.to_atom(key), val}
  end

  def build_string_map(input_map) do
    for {key, val} <- input_map, into: %{}, do: {Atom.to_string(key), val}
  end
end
