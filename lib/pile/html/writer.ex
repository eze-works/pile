defmodule Pile.Html.Writer do
  @moduledoc false

  def new(options) do
    if Keyword.get(options, :indent, false) do
      {:indent, 0, []}
    else
      {:noindent, nil, []}
    end
  end

  def append_start_tag({:noindent, _, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:noindent, nil, ["<#{element}#{attributes}>" | str]}
  end

  def append_start_tag({:indent, level, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:indent, level + 1, ["#{get_indent(level)}<#{element}#{attributes}>\n" | str]}
  end

  def append_end_tag({:noindent, _, str}, element) do
    {:noindent, nil, ["</#{element}>" | str]}
  end

  def append_end_tag({:indent, level, str}, element) do
    {:indent, level - 1, ["#{get_indent(level - 1)}</#{element}>\n" | str]}
  end

  def append_void_tag({:noindent, _, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:noindent, nil, ["<#{element}#{attributes}>" | str]}
  end

  def append_void_tag({:indent, level, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:indent, level, ["#{get_indent(level)}<#{element}#{attributes}>\n" | str]}
  end

  def append_text({:noindent, _, str}, text) do
    {:noindent, nil, [text | str]}
  end

  def append_text({:indent, level, str}, text) do
    margin = "\n#{get_indent(level)}"
    indented_text = text |> String.trim_trailing("\n") |> String.replace("\n", margin)
    {:indent, level, ["#{get_indent(level)}#{indented_text}\n" | str]}
  end

  def finish({mode, _, str})
      when mode == :indent
      when mode == :noindent do
    str |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp get_indent(level), do: String.duplicate("  ", level)

  defp format_attributes(%{} = attributes) do
    attributes
    |> Map.to_list()
    |> Enum.map(fn {key, value} ->
      {key |> String.Chars.to_string() |> String.replace("_", "-"), value}
    end)
    |> Enum.map(&attribute_to_string/1)
    |> Enum.filter(&Function.identity/1)
    |> Enum.join("")
  end

  defp attribute_to_string({_key, false}), do: nil
  defp attribute_to_string({_key, nil}), do: nil
  defp attribute_to_string({key, true}), do: " #{key}"
  defp attribute_to_string({key, value}), do: ~s( #{key}="#{value}")
end
