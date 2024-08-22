defmodule Pile.Html.Visitor.StyleProcessorTest do
  use ExUnit.Case, async: true

  alias Pile.Html.Visitor.StyleProcessor
  alias Pile.Html.Visitor.StyleCollector

  test "returns an identical html structure when style attribute is not present" do
    node = {
      :body,
      [
        %{class: "container"},
        nav: [%{class: "navigation"}],
        input: [%{type: "text"}],
        _text: "Submit"
      ]
    }

    result = Pile.Html.Visitor.traverse(node, StyleProcessor, [])
    assert result == node
  end

  test "ignores string style properties" do
    node = {:p, [%{style: "display: none;"}]}
    result = Pile.Html.Visitor.traverse(node, StyleProcessor, [])
    assert result == node
  end

  test "de-duplicates styles" do
    css = Pile.css("background-color: black;")

    node = {
      :body,
      [
        p: [
          %{css: css},
          span: [
            %{css: css}
          ]
        ],
      ]
    }

    result = Pile.Html.Visitor.traverse(node, StyleCollector, [])
    dbg(result)
  end
end
