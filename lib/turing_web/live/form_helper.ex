defmodule TuringWeb.Live.FormHelper do
  @moduledoc """
  Provides FormHelper  functions
  """

  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag, only: [tag: 2]

  def live_view_password_input(form, field, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:type, "password")
      |> Keyword.put_new(:id, input_id(form, field))
      |> Keyword.put_new(:name, input_name(form, field))
      |> Keyword.put_new(:value, input_value(form, field))

    tag(:input, opts)
  end
end
