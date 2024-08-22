defmodule Pile.Visitor.Serializer do
  @moduledoc false
  @behaviour Pile.Visitor

  @impl true
  def init(opts) do
    Pile.Writer.new(opts)
  end

  @impl true
  def visit_text(writer, :_text, text) do
    Pile.Writer.append_text(writer, escape_text(text))
  end

  @impl true
  def visit_text(writer, :_rawtext, text) do
    Pile.Writer.append_text(writer, text)
  end

  @impl true
  def visit_void_element(writer, tag, attributes) do
    Pile.Writer.append_void_tag(writer, tag, attributes)
  end

  @impl true
  def visit_element_start(writer, tag, attributes) do
    Pile.Writer.append_start_tag(writer, tag, attributes)
  end

  @impl true
  def visit_element_end(writer, tag) do
    Pile.Writer.append_end_tag(writer, tag)
  end

  @impl true
  def finish(writer) do
    Pile.Writer.finish(writer)
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
