defmodule Pile do
  @moduledoc """

  ## Introduction
  This library provides a way to convert plain Elixir data structures into HTML.

      iex> data = [
      ...>   doctype!: %{html: true},
      ...>   html: [
      ...>     head: [
      ...>       title: "Hello World"
      ...>     ]
      ...>   ]
      ...> ]
      iex> Pile.to_html(data)
      "<doctype! html><html><head><title>Hello World</title></head></html>"
    
    See `Pile.to_html/2` for details about shape of data structure 


  """
  @default_options_to_html [pretty: false]

  @spec to_html(input :: keyword(), options :: keyword()) :: String.t()
  @doc ~S"""
  Converts an Elixir keyword list into to an HTML string

  ## Options:

  - `pretty`: Passing `true` causes the HTML output to be pretty-printed. Defaults to `false`

  ## Input structure: 

  Keys represents HTML elements and values represents their children. 

      iex> Pile.to_html([div: [p: ["hello"]]])
      "<div><p>hello</p></div>"

  If an element only has one text child, you do not need to put it in a list

      iex> Pile.to_html([div: [p: "hello"]])
      "<div><p>hello</p></div>"

  Attributes are represented as a map at the start of a list:

      iex> Pile.to_html([div: [%{class: "container"}, p: "hello"]])
      "<div class=\"container\"><p>hello</p></div>"

  If an element has attributes, but not children, you do not need to put it in a list

      iex> Pile.to_html([div: %{class: "container"}])
      "<div class=\"container\"></div>"
  """
  def to_html(input, options \\ @default_options_to_html)

  def to_html([], _opts), do: ""

  def to_html([_ | _] = input, opts) do
    opts = Keyword.validate!(opts, @default_options_to_html)

    if not Keyword.keyword?(input) do
      raise(ArgumentError, "input should be a keyword list")
    end

    input =
      input
      |> Enum.map(fn {atom, value} -> Pile.Normalize.run({atom, value}) end)

    rulesets =
      input
      |> Enum.flat_map(fn node ->
        Pile.Visitor.traverse(node, Pile.Visitor.RulesetCollector, [])
      end)
      |> Enum.map(fn ruleset -> ruleset.content end)
      |> MapSet.new()
      |> Enum.join("\n")

    # if there is already a `<head>` element in the html, place the style in it.
    # Otherwise, prepend it to whatever html we have
    path =
      if input[:html][:head] do
        [:html, :head, :style]
      else
        [:style]
      end

    input =
      if String.length(rulesets) > 0 do
        put_in(input, path, _rawtext: rulesets)
      else
        input
      end

    input
    |> Enum.map(fn node ->
      Pile.Visitor.traverse(node, Pile.Visitor.Serializer, opts)
    end)
    |> Enum.join("")
  end

  @doc """
  Creates a CSS ruleset that can be attached as an attribute to an HTML element
  """
  def css(declaration_block) do
    Pile.Ruleset.new(declaration_block)
  end
end
