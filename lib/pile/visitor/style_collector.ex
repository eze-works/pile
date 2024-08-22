# This visitor returns a list of paths to elements with a `css` attribute
# This is done keeping track of the path to elements as we open and close them
defmodule Pile.Visitor.StyleCollector do
  @moduledoc false

  @behaviour Pile.Visitor

  @impl Pile.Visitor
  def init(_opts) do
    %{
      current_path: [],
      paths: []
    }
  end

  @impl true
  def visit_element_start(state, tag, attributes) do
    state = %{state | current_path: [tag | state.current_path]}

    if has_ruleset(attributes) do
      %{state | paths: [state.current_path | state.paths]}
    else
      state
    end
  end

  @impl true
  def visit_element_end(state, tag) do
    [^tag | rest] = state.current_path
    %{state | current_path: rest}
  end

  @impl true
  def visit_void_element(state, tag, attributes) do
    visit_element_end(visit_element_start(state, tag, attributes), tag)
  end

  @impl true
  def visit_text(state, _tag, _text), do: state

  @impl true
  def finish(state) do
    state.paths |> Enum.map(&Enum.reverse/1)
  end

  defp has_ruleset(%{css: %Pile.Ruleset{}}), do: true
  defp has_ruleset(_), do: false
end
