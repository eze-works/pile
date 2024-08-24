# This module implements the visitor pattern to traverse an HTML tree. 
#
# A concrete visitor will implement the `Pile.Visitor` behavior to do
# whatever it needs to with each node while the tree is being traversed.
#
# Structuring things this way separates the tree traversal code from whatever
# we'd like to do while traversing it.
defmodule Pile.Visitor do
  @moduledoc false

  @type state :: any()

  @doc """
  Returns the visitor's initial state
  """
  @callback init(keyword()) :: state()

  @doc """
  Handles an HTML text node. `atom` may be either `:_text` or `_rawtext`
  """
  @callback visit_text(state(), tag :: atom(), String.t()) :: state()

  @doc """
  Handles an HTML void element.
  """
  @callback visit_void_element(state(), tag :: atom(), attributes :: map()) :: state()

  @doc """
  Handles the start tag of a non-void HTML element
  """
  @callback visit_element_start(state(), tag :: atom(), attributes :: map()) :: state()

  @doc """
  Handles the end of a non-void HTML element
  """
  @callback visit_element_end(state(), atom()) :: state()

  @doc """
  Handles the end of processing the HTML tree and returns the result
  """
  @callback finish(state()) :: state()

  @void_elements [
    "area",
    "base",
    "br",
    "col",
    "embed",
    "hr",
    "img",
    "input",
    "link",
    "meta",
    "source",
    "track",
    "wbr",
    "!doctype"
  ]

  # HTML TREE TRAVERSAL 
  #
  # A standard depth-first traversal of an HTML tree. The visitor callbacks are
  # called whenever text, void, start and end tags are encountered.
  @doc false
  def traverse({tag, definition}, visitor, visitor_options) do
    state = visitor.init(visitor_options)
    _traverse([{:open, tag, definition}], visitor, state)
  end

  defp _traverse([{:open, atom, text} | rest], visitor, state)
       when atom == :_text
       when atom == :_rawtext do
    new_state = visitor.visit_text(state, atom, text)
    _traverse(rest, visitor, new_state)
  end

  defp _traverse([{:open, :_nil, nil} | rest], visitor, state) do
    _traverse(rest, visitor, state)
  end

  defp _traverse([{:open, :_, list} | rest], visitor, state) when is_list(list) do
    children = list |> Enum.map(fn {atom, value} -> {:open, atom, value} end)
    stack = children ++ rest
    _traverse(stack, visitor, state)
  end

  defp _traverse([{:open, tag, value} | rest], visitor, state) do
    {occurences, children} = Keyword.pop_values(value, :_attr)
    attributes = List.first(occurences) || []

    cond do
      Enum.member?(@void_elements, String.downcase(Atom.to_string(tag))) ->
        new_state = visitor.visit_void_element(state, tag, attributes)
        _traverse(rest, visitor, new_state)

      true ->
        new_state = visitor.visit_element_start(state, tag, attributes)
        children = Enum.map(children, fn {element, payload} -> {:open, element, payload} end)

        stack = children ++ [{:close, tag} | rest]
        _traverse(stack, visitor, new_state)
    end
  end

  defp _traverse([{:close, tag} | rest], visitor, state) do
    new_state = visitor.visit_element_end(state, tag)
    _traverse(rest, visitor, new_state)
  end

  defp _traverse([], visitor, state) do
    visitor.finish(state)
  end
end
