# This visitor builds a new tree that incorporates css style declarations found along the way
defmodule Pile.Html.Visitor.StyleProcessor do
  @moduledoc false

  @behaviour Pile.Html.Visitor

  @impl Pile.Html.Visitor
  def init(_opts) do
    %{
      # A stack of tuples to keep track of our location in the HTML hierarchy
      nesting_stack: [],

      # Keeps track of the children of the current nesting level
      element_stack: []
    }
  end

  @impl Pile.Html.Visitor
  def visit_element_start(state, tag, attributes) do
    # Extract styles if present and update the `class` attribute accordingly
    {attributes, ruleset} =
      case extract_ruleset(attributes) do
        {:found, ruleset, attributes} ->
          updated =
            Map.update(attributes, :class, ruleset.name, fn c -> "#{c} #{ruleset.name}" end)

          {attributes, updated}

        :notfound ->
          {attributes, nil}
      end

    {attributes, style_element} =
      case extract_ruleset(attributes) do
        {:found, ruleset, attributes} ->
          updated =
            Map.update(attributes, :class, ruleset.name, fn c -> "#{c} #{ruleset.name}" end)

          style_element = {:style, ruleset.content}
          {updated, style_element}

        :notfound ->
          {attributes, nil}
      end

    # Push onto the `nesting_stack` when we encounter the start of an element
    # Include the number of elements already in `element_stack` so that we can
    # figure out where the children of the current element begin
    nesting_stack = [{tag, attributes, length(state.element_stack)} | state.nesting_stack]

    element_stack =
      if style_element do
        [style_element | state.element_stack]
      else
        state.element_stack
      end

    %{state | nesting_stack: nesting_stack, element_stack: element_stack}
  end

  @impl Pile.Html.Visitor
  def visit_element_end(state, tag) do
    # Pop from the `nesting_stack` when we encounter the end of an element.
    # The html structure is guaranteed to be well balanced, so the tag that
    # just closed must match the latest one that opened
    [{^tag, attributes, count} | nesting_stack] = state.nesting_stack

    {children, element_stack} =
      Enum.split(state.element_stack, length(state.element_stack) - count)

    element = {tag, [attributes | Enum.reverse(children)]}

    %{state | nesting_stack: nesting_stack, element_stack: [element | element_stack]}
  end

  @impl Pile.Html.Visitor
  def visit_void_element(state, tag, attributes) do
    # A void element has no children and can be put on the element_stack immediately
    element = {tag, [attributes]}
    %{state | element_stack: [element | state.element_stack]}
  end

  @impl Pile.Html.Visitor
  def visit_text(state, tag, text) do
    element = {tag, text}
    %{state | element_stack: [element | state.element_stack]}
  end

  @impl Pile.Html.Visitor
  def finish(%{nesting_stack: [], element_stack: [root]}) do
    # The html structure is guranteed to be balanced,  so by the time we finish traversing (i.e. we've visited the end of the root node),
    # the nesting stack should be empty and there should be only one element left.
    root
  end

  defp extract_ruleset(%{style: %Pile.Css.Ruleset{}} = attributes) do
    {:found, attributes.style, Map.delete(attributes, :style)}
  end

  defp extract_ruleset(_), do: :notfound
end
