defmodule Pile.NormalizeTest do
  use ExUnit.Case, async: true

  import Pile.Normalize, only: [run: 1]

  test "_nil tuples do not change" do
    assert(run({:_nil, nil}) == {:_nil, nil})
  end

  test "a tuple with an empty array value gets its value converted to a _nil tuple" do
    assert run({:div, []}) == {:div, [_nil: nil]}
  end

  test "standalone empty arrays get converted to _nil tuples" do
    assert run([]) == {:_nil, nil}
  end

  test "_text tuples do not change" do
    assert run({:_text, "foo"}) == {:_text, "foo"}
  end

  test "a tuple with a text value gets its value converted to a _text tuple" do
    assert run({:div, "foo"}) == {:div, [_text: "foo"]}
  end

  test "standalone text gets converted to _text tuples" do
    assert run({:div, ["foo"]}) == {:div, [_text: "foo"]}
    assert run("foo") == {:_text, "foo"}
  end

  test "_rawtext tuples do not change" do
    assert run({:_rawtext, "foo"}) == {:_rawtext, "foo"}
  end

  test "_attr tuples do not change" do
    assert run({:_attr, %{}}) == {:_attr, %{}}
  end

  test "a tuple with a map as a value gets its value converted to an _attr tuple" do
    assert run({:div, %{}}) == {:div, [_attr: %{}]}
  end

  test "standalone map gets converted to an _attr tuple" do
    assert run({:div, [%{}]}) == {:div, [_attr: %{}]}
    assert run(%{}) == {:_attr, %{}}
  end

  test "ruleset in attr is used to populate the class attribute" do
    assert run(%{css: %Pile.Ruleset{name: "foo"}}) ==
             {:_attr, %{css: %Pile.Ruleset{name: "foo"}, class: "foo"}}
  end

  test "lists are flattened" do
    assert run({:div, [[p: "foo"]]}) == {:div, [p: [_text: "foo"]]}
  end

  test "recursive cases" do
    assert run({:div, ["foo", %{}]}) == {:div, [_text: "foo", _attr: %{}]}
    assert run({:div, [span: [p: []]]}) == {:div, [span: [p: [_nil: nil]]]}
  end
end
