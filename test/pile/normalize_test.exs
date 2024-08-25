defmodule Pile.NormalizeTest do
  use ExUnit.Case, async: true

  import Pile.Normalize, only: [run: 1]

  test "text represents itself" do
    assert run("foo") == "foo"
  end

  test "text is escaped" do
    assert run(~S(<'ole &"foo>)) == "&lt;&#39;ole &amp;&quot;foo&gt;"
  end

  test "a _rawtext gets converted to text" do
    assert run({:_rawtext, "foo"}) == "foo"
  end

  test "_rawtext is not escaped" do
    assert run({:_rawtext, "<span>"}) == "<span>"
  end

  test "single element tuple gets expanded" do
    assert run({:div}) == {:div, %{}, []}
  end

  test "tuple without children gets an empty list appended" do
    assert run({:div, %{}}) == {:div, %{}, []}
  end

  test "tuple without attributes gets an empty map inserted" do
    assert run({:div, []}) == {:div, %{}, []}
  end

  test "a tuple with a text value gets its value injected into a list" do
    assert run({:div, "foo"}) == {:div, %{}, ["foo"]}
  end

  test "a tuple with a tuple value gets its value inserted into a list" do
    assert run({:div, {:p}}) == {:div, %{}, [{:p, %{}, []}]}
  end

  test "three element tuples" do
    assert run({:div, %{a: "b"}, "foo"}) == {:div, %{a: "b"}, ["foo"]}
    assert run({:div, %{a: "b"}, [{:p}]}) == {:div, %{a: "b"}, [{:p, %{}, []}]}
    assert run({:div, %{a: "b"}, {:p}}) == {:div, %{a: "b"}, [{:p, %{}, []}]}
  end

  test "nested children get flattend" do
    data = {:div, [[{:p}], [{:span}]]}
    assert run(data) == {:div, %{}, [{:p, %{}, []}, {:span, %{}, []}]}
  end
end
