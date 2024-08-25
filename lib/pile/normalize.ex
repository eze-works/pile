# Library users can ommit attributes, children or both.
#
# The traversal algorithm is simplified if the input has a rigid shape, so this
# module takes care of filling in empty attributes and children where there are
# missing.
defmodule Pile.Normalize do
  @moduledoc false

  def run(text) when is_binary(text) do
    escape_text(text)
  end

  def run({:_rawtext, text}) do
    text
  end

  def run({atom}) when is_atom(atom) do
    run({atom, %{}, []})
  end

  def run({atom, text}) when is_atom(atom) and is_binary(text) do
    run({atom, %{}, [text]})
  end

  def run({atom, map}) when is_atom(atom) and is_map(map) do
    run({atom, map, []})
  end

  def run({atom, list}) when is_atom(atom) and is_list(list) do
    run({atom, %{}, list})
  end

  def run({atom, tuple}) when is_atom(atom) and is_tuple(tuple) do
    run({atom, %{}, [tuple]})
  end

  def run({atom, map, text}) when is_atom(atom) and is_map(map) and is_binary(text) do
    run({atom, map, [text]})
  end

  def run({atom, map, tuple}) when is_atom(atom) and is_map(map) and is_tuple(tuple) do
    run({atom, map, [tuple]})
  end

  def run({atom, map, list}) when is_atom(atom) and is_map(map) and is_list(list) do
    children = List.flatten(list)
    {atom, map, Enum.map(children, &run/1)}
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
