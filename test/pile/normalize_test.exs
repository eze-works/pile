defmodule Pile.NormalizeTest do
  use ExUnit.Case, async: true

  import Pile.Normalize, only: [run: 1]

  test "input normalization" do
    test_cases = [
      # _nil tuples do not change
      {{:_nil, nil}, {:_nil, nil}},
      # a tuple with an empty array value gets its value converted to a _nil tuple
      {{:div, []}, {:div, [_nil: nil]}},
      # Standalone empty arrays get converted to _nil tuple
      {[], {:_nil, nil}},

      # _text tuples do not change
      {{:_text, "foo"}, {:_text, "foo"}},
      # a tuple with a text value gets its value converted to a _text tuple
      {{:div, "foo"}, {:div, [_text: "foo"]}},
      # standalone text gets converted to a _text tuple
      {{:div, ["foo"]}, {:div, [_text: "foo"]}},
      {"foo", {:_text, "foo"}},

      # _rawtext tuples do not change
      {{:_rawtext, "foo"}, {:_rawtext, "foo"}},

      # _attr tuples do not change
      {{:_attr, %{}}, {:_attr, %{}}},
      # a tuple with a map as a value gets its value converted to an _attr tuple
      {{:div, %{}}, {:div, [_attr: %{}]}},
      # a standalone map gets converted to an _attr tuple
      {{:div, [%{}]}, {:div, [_attr: %{}]}},
      {%{}, {:_attr, %{}}},

      # Recursive cases
      {{:div, [[], "foo", %{}]}, {:div, [_nil: nil, _text: "foo", _attr: %{}]}},
      {{:div, [span: [p: []]]}, {:div, [span: [p: [_nil: nil]]]}}
    ]

    for case <- test_cases do
      {input, output} = case
      assert(run(input) == output)
    end
  end
end
