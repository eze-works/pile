defmodule Pile.Visitor.RulesetCollector do
  @moduledoc false
  @behaviour Pile.Visitor

  @impl true
  def init(_opts) do
    []
  end

  @impl true
  def visit_text(state, _atom, _text), do: state

  @impl true
  def visit_void_element(state, _tag, %{css: %Pile.Ruleset{}} = attributes) do
    [attributes.css | state]
  end

  def visit_void_element(state, _tag, _attributes), do: state

  @impl true
  def visit_element_start(state, _tag, %{css: %Pile.Ruleset{}} = attributes) do
    [attributes.css | state]
  end

  def visit_element_start(state, _tag, _attributes), do: state

  @impl true
  def visit_element_end(state, _tag), do: state

  @impl true
  def finish(state) do
    state
  end
end
