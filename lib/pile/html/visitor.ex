# This module implements the visitor pattern to traverse an HTML tree. 
#
# A concrete visitor will implement the `Pile.Html.Visitor` behavior to do
# whatever it needs to with each node while the tree is being traversed.
#
# Structuring things this way separates the tree traversal code from whatever
# we'd like to do while traversing it.
defmodule Pile.Html.Visitor do
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
    :area,
    :base,
    :br,
    :col,
    :embed,
    :hr,
    :img,
    :input,
    :link,
    :meta,
    :source,
    :track,
    :wbr
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

  defp _traverse([{:open, tag, value} | rest], visitor, state) do
    {attributes, children} =
      case value do
        string when is_binary(string) -> {%{}, string}
        [map | rest] when is_map(map) -> {map, rest}
        [tuple | _] when is_tuple(tuple) -> {%{}, value}
        [] -> {%{}, []}
        x -> raise(ArgumentError, "Expected tuple, map or string. Got <#{inspect(x)}>")
      end

    cond do
      Enum.member?(@void_elements, tag) ->
        new_state = visitor.visit_void_element(state, tag, attributes)
        _traverse(rest, visitor, new_state)

      is_binary(children) ->
        new_state = visitor.visit_element_start(state, tag, attributes)
        # Don't mess with the text in <script> & <style> tags
        text_tag =
          if tag == :script or tag == :style do
            :_rawtext
          else
            :_text
          end

        stack = [{:open, text_tag, children} | [{:close, tag} | rest]]
        _traverse(stack, visitor, new_state)

      true ->
        new_state = visitor.visit_element_start(state, tag, attributes)

        children =
          children
          |> Enum.filter(&Function.identity/1)
          |> Enum.map(fn {element, payload} -> {:open, element, payload} end)

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
