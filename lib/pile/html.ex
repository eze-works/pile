defmodule Pile.Html do
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

  @default_print_options [indent: false]

  # Depth-first traversal to convert the html structure into a string
  # When visiting opening and closing tags, the element is tagged with `:open` and `:close` respectively.
  def to_html(input, options \\ @default_print_options) do
    options = Keyword.validate!(options, @default_print_options)

    fragments =
      for {tag, definition} <- input do
        _to_html([{:open, tag, definition}], Pile.Html.Writer.new(options))
      end

    Enum.join(fragments, "")
  end

  defp _to_html([{:open, :_text, text} | rest], writer) do
    _to_html(rest, Pile.Html.Writer.append_text(writer, escape_text(text)))
  end

  defp _to_html([{:open, :_rawtext, text} | rest], writer) do
    _to_html(rest, Pile.Html.Writer.append_text(writer, text))
  end

  defp _to_html([{:open, tag, value} | rest], writer) when is_list(value) do
    {attributes, children} =
      case value do
        [map | list] when is_map(map) and is_list(list) -> {map, list}
        [tuple | list] when is_tuple(tuple) and is_list(list) -> {%{}, value}
        [] -> {%{}, []}
        x -> raise(ArgumentError, "Expected tuple or map. Got <#{inspect(x)}>")
      end

    {stack, writer} =
      if Enum.member?(@void_elements, tag) do
        stack = rest
        {stack, Pile.Html.Writer.append_void_tag(writer, tag, attributes)}
      else
        children = Enum.map(children, fn {element, payload} -> {:open, element, payload} end)
        stack = children ++ [{:close, tag} | rest]
        {stack, Pile.Html.Writer.append_start_tag(writer, tag, attributes)}
      end

    _to_html(stack, writer)
  end

  defp _to_html([{:close, element} | rest], writer) do
    _to_html(rest, Pile.Html.Writer.append_end_tag(writer, element))
  end

  defp _to_html([], writer) do
    Pile.Html.Writer.finish(writer)
  end

  defp escape_text(text) when is_binary(text) do
    escaped =
      for byte <- :binary.bin_to_list(text) do
        case byte do
          ?" -> "&quot;"
          ?' -> "&#39;"
          ?& -> "&amp;"
          ?< -> "&lt;"
          ?> -> "&gt;"
          b -> b
        end
      end

    IO.iodata_to_binary(escaped)
  end
end
