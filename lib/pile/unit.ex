defmodule Pile.Unit do
  @moduledoc """
  Functions for creating CSS values with units
  """

  def px(n) when is_number(n), do: "#{n}px"

  def em(n) when is_number(n), do: "#{n}em"

  def rem(n) when is_number(n), do: "#{n}rem"

  def pct(n) when is_number(n), do: "#{n}%"
end
