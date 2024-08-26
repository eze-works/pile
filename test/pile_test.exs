defmodule PileTest do
  use ExUnit.Case, async: true

  doctest(Pile)
  import Pile

  test "single element" do
    assert {:div} |> to_html() == "<div></div>"
  end

  test "void element" do
    assert {:img, {:p}} |> to_html() == "<img>"
    assert {:IMG, {:p}} |> to_html() == "<IMG>"
  end

  test "element with a child" do
    assert {:div, {:p}} |> to_html() == "<div><p></p></div>"
  end

  test "element with text child" do
    assert {:div, "foo"} |> to_html() == "<div>foo</div>"
  end

  test "element with multple children" do
    assert {:div, [{:p}, {:p}]} |> to_html() == "<div><p></p><p></p></div>"
    assert {:div, [{:p}, "foo"]} |> to_html() == "<div><p></p>foo</div>"
  end

  test "children nested in arrays get flattend" do
    assert {:div, [[[{:p}]], {:p}]} |> to_html() == "<div><p></p><p></p></div>"
  end

  test "element with attributes" do
    assert {:div, %{class: "container"}} |> to_html() == "<div class=\"container\"></div>"
    assert {:div, %{async: true}} |> to_html() == "<div async></div>"
    assert {:div, %{async: false}} |> to_html() == "<div></div>"
    assert {:div, %{async: nil}} |> to_html() == "<div></div>"
  end

  test "outputing iodata" do
    assert {:div, {:p}} |> to_html(iodata: true) == [["<div>", "<p>", "</p>", "</div>"]]
  end

  test "prepending the doctype" do
    assert {:div} |> to_html(doctype: true) == "<!DOCTYPE html><div></div>"
  end
end
