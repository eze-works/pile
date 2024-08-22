# This visitor returns a list of paths to elements with a `css` attribute
defmodule Pile.Html.Visitor.StyleCollector do
  @moduledoc false

  @behaviour Pile.Html.Visitor

  @impl Pile.Html.Visitor
  def init(_opts) do
    %{
      current_path: [],
      paths: []
    }
  end

  @impl Pile.Html.Visitor
  def visit_element_start(state, tag, attributes) do
    state = %{state | current_path: [tag | state.current_path]}

    if has_ruleset(attributes) do
      %{state | paths: [state.current_path | state.paths]}
    else
      state
    end
  end

  @impl Pile.Html.Visitor
  def visit_element_end(state, _tag), do: state

  @impl Pile.Html.Visitor
  def visit_void_element(state, tag, attributes), do: visit_element_start(state, tag, attributes)

  @impl Pile.Html.Visitor
  def visit_text(state, _tag, _text), do: state

  @impl Pile.Html.Visitor
  def finish(state) do
    state.paths |> Enum.map(&Enum.reverse/1)
  end

  defp has_ruleset(%{css: %Pile.Css.Ruleset{}}), do: true
  defp has_ruleset(_), do: false
end
