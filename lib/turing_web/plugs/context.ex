defmodule TuringWeb.Context do
  @moduledoc """
  Context Plug to build context after authorize
  """

  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        Absinthe.Plug.put_options(conn, context: context)

      {:error, _reason} ->
        conn

      _ ->
        conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      {:ok, %{current_user: current_user, metadata: %{token: token}}}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    case Turing.Auth.Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        return_user(claims)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp return_user(claims) do
    Turing.Auth.Guardian.resource_from_claims(claims)
  end
end
