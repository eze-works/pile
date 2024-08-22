defmodule Pile do
  @doc """
  Creates a CSS ruleset that can be attached as an attribute to an HTML element
  """
  def css(declaration_block) do
    Pile.Css.Ruleset.new(declaration_block)
  end
end
