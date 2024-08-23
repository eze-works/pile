# At its core, this library operates on a nested keyword list.
# Keys are atoms named after the desired HTML element.
# Values are keyword lists (or maps in the case of attributes)
#
# This would be very cumbersome for end users. Imagine having to write this
#
# ```
# [
#   div: [
#     p: [
#       _attr: %{},
#       span: [
#         _text: "Hello world"
#       ],
#       img: [
#         _nil: nil
#       ]
#     ]
#   ]
# ]
# ```
#
# Operating on a strict datastructure makes the code more straightforward at the expense of user experience.
#
# To remedy, users can use a more simplified datastructure that is uh... `Normalize`d into what the rest of the library expects
# 
# The above example can now be written as long as it is passed through the `run` function
#
# ```
# [
#  div: [
#    p: [
#      %{},
#      span: "Hello world"
#    ]
#    img: []
#  ]
# ]
# ```
defmodule Pile.Normalize do
  @moduledoc false

  def run({:_text, text} = input) when is_binary(text) or is_number(text) do
    input
  end

  def run({:_rawtext, text} = input) when is_binary(text) or is_number(text) do
    input
  end

  def run({:_attr, map} = input) when is_map(map) do
    input
  end

  def run({:_nil, _} = input) do
    input
  end

  def run({atom, map}) when is_atom(atom) and is_map(map) do
    {atom, [run(map)]}
  end

  def run(map) when is_map(map) do
    {:_attr, map}
  end

  def run({atom, text})
      when is_atom(atom) and is_binary(text)
      when is_atom(atom) and is_number(text) do
    {atom, [run(text)]}
  end

  def run(text) when is_binary(text) or is_number(text) do
    {:_text, text}
  end

  def run([]) do
    {:_nil, nil}
  end

  def run({atom, []}) do
    {atom, [run([])]}
  end

  def run({atom, list}) when is_atom(atom) and is_list(list) do
    {atom, list |> List.flatten |> Enum.map(fn member -> run(member) end)}
  end
end
