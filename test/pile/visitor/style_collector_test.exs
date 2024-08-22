defmodule Pile.Visitor.StyleCollectorTest do
  use ExUnit.Case, async: true

  alias Pile.Visitor.StyleCollector
  import Pile.Visitor, only: [traverse: 3]

  test "returns empty list when no css attributes exist" do
    node = {:body, [p: [%{class: "card"}]]}
    assert traverse(node, StyleCollector, []) == []
  end

  test "returns list of paths to elements with a `css` attribute" do
    css = Pile.css("background-color: black;")

    node =
      {:body,
       [
         %{css: css},
         div: [
           %{css: css},
           p: [
             %{css: css},
             i: []
           ]
         ],
         header: [],
         img: [
           %{css: css}
         ]
       ]}

    assert traverse(node, StyleCollector, []) == [
             [:body, :img],
             [:body, :div, :p],
             [:body, :div],
             [:body]
           ]
  end
end
