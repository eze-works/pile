defmodule Pile.Visitor.Serializer do
  @moduledoc false
  @behaviour Pile.Visitor

  @impl true
  def init(options) do
    if Keyword.get(options, :pretty, false) do
      {:pretty, 0, []}
    else
      {:ugly, nil, []}
    end
  end

  @impl true
  def visit_element_start({:ugly, _, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:ugly, nil, ["<#{element}#{attributes}>" | str]}
  end

  def visit_element_start({:pretty, level, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:pretty, level + 1, ["#{get_indent(level)}<#{element}#{attributes}>\n" | str]}
  end

  @impl true
  def visit_element_end({:ugly, _, str}, element) do
    {:ugly, nil, ["</#{element}>" | str]}
  end

  def visit_element_end({:pretty, level, str}, element) do
    {:pretty, level - 1, ["#{get_indent(level - 1)}</#{element}>\n" | str]}
  end

  @impl true
  def visit_void_element({:ugly, _, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:ugly, nil, ["<#{element}#{attributes}>" | str]}
  end

  def visit_void_element({:pretty, level, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:pretty, level, ["#{get_indent(level)}<#{element}#{attributes}>\n" | str]}
  end

  @impl true
  def visit_text({:ugly, _, str}, text) do
    {:ugly, nil, [text | str]}
  end

  def visit_text({:pretty, level, str}, text) do
    margin = "\n#{get_indent(level)}"
    indented_text = text |> String.trim_trailing("\n") |> String.replace("\n", margin)
    {:pretty, level, ["#{get_indent(level)}#{indented_text}\n" | str]}
  end

  @impl true
  def finish({_, _, str}), do: str |> Enum.reverse()

  defp get_indent(level), do: String.duplicate("  ", level)

  defp format_attributes(attributes) do
    attributes
    |> Enum.map(&attribute_to_string/1)
    |> Enum.filter(&Function.identity/1)
    |> Enum.join("")
  end

  defp attribute_to_string({_key, false}), do: nil
  defp attribute_to_string({_key, nil}), do: nil
  defp attribute_to_string({key, true}), do: " #{key}"
  defp attribute_to_string({key, value}), do: ~s( #{key}="#{value}")
end
