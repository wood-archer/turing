defmodule Turing.Utils.Constants do
  def default_signup_coin_account_balance, do: 10_000
  # n outta 10 times
  def match_among_humans_probability, do: 7
  # Maintain n active bot processes always  
  def number_of_bot_users, do: 2
end
