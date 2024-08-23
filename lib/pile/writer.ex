defmodule Pile.Writer do
  @moduledoc false

  def new(options) do
    if Keyword.get(options, :pretty, false) do
      {:pretty, 0, []}
    else
      {:ugly, nil, []}
    end
  end

  def append_start_tag({:ugly, _, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:ugly, nil, ["<#{element}#{attributes}>" | str]}
  end

  def append_start_tag({:pretty, level, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:pretty, level + 1, ["#{get_indent(level)}<#{element}#{attributes}>\n" | str]}
  end

  def append_end_tag({:ugly, _, str}, element) do
    {:ugly, nil, ["</#{element}>" | str]}
  end

  def append_end_tag({:pretty, level, str}, element) do
    {:pretty, level - 1, ["#{get_indent(level - 1)}</#{element}>\n" | str]}
  end

  def append_void_tag({:ugly, _, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:ugly, nil, ["<#{element}#{attributes}>" | str]}
  end

  def append_void_tag({:pretty, level, str}, element, attributes) do
    attributes = format_attributes(attributes)
    {:pretty, level, ["#{get_indent(level)}<#{element}#{attributes}>\n" | str]}
  end

  def append_text({:ugly, _, str}, text) do
    {:ugly, nil, [text | str]}
  end

  def append_text({:pretty, level, str}, text) do
    margin = "\n#{get_indent(level)}"
    indented_text = text |> String.trim_trailing("\n") |> String.replace("\n", margin)
    {:pretty, level, ["#{get_indent(level)}#{indented_text}\n" | str]}
  end

  def finish({mode, _, str})
      when mode == :pretty
      when mode == :ugly do
    str |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp get_indent(level), do: String.duplicate("  ", level)

  defp format_attributes(attributes) do
    attributes
    |> Enum.map(fn {key, value} ->
      {key |> String.Chars.to_string() |> String.replace("_", "-"), value}
    end)
    |> Enum.map(&attribute_to_string/1)
    |> Enum.filter(&Function.identity/1)
    |> Enum.join("")
  end

  defp attribute_to_string({"css", _}), do: nil
  defp attribute_to_string({_key, false}), do: nil
  defp attribute_to_string({_key, nil}), do: nil
  defp attribute_to_string({key, true}), do: " #{key}"
  defp attribute_to_string({key, value}), do: ~s( #{key}="#{value}")
end
