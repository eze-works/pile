defmodule Pile.Html.Visitor.Serializer do
  @moduledoc false
  @behaviour Pile.Html.Visitor

  @impl Pile.Html.Visitor
  def init(opts) do
    Pile.Html.Writer.new(opts)
  end

  @impl Pile.Html.Visitor
  def visit_text(writer, :_text, text) do
    Pile.Html.Writer.append_text(writer, escape_text(text))
  end

  @impl Pile.Html.Visitor
  def visit_text(writer, :_rawtext, text) do
    Pile.Html.Writer.append_text(writer, text)
  end

  @impl Pile.Html.Visitor
  def visit_void_element(writer, tag, attributes) do
    Pile.Html.Writer.append_void_tag(writer, tag, attributes)
  end

  @impl Pile.Html.Visitor
  def visit_element_start(writer, tag, attributes) do
    Pile.Html.Writer.append_start_tag(writer, tag, attributes)
  end

  @impl Pile.Html.Visitor
  def visit_element_end(writer, tag) do
    Pile.Html.Writer.append_end_tag(writer, tag)
  end

  @impl Pile.Html.Visitor
  def finish(writer) do
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
