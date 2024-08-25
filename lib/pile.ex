defmodule Pile do
  @moduledoc ~S"""
  This library allows representing HTML in Elixir. It uses tuples to represent elements, and maps to represent element attributes:
    
      iex> {:html,
      ...>   {:head, 
      ...>     {:title, "Hello World"},
      ...>     {:link, %{rel: "stylesheet", href: "..."}},    
      ...>   }
      ...> }
      ...> |> Pile.to_html()
      ...> 
      "<html><head><title>Hello World</title><link rel=\"stylesheet\" href=\"...\"></head></html>"
    
    See `Pile.to_html/2` for more details about the syntax 
  """

  @default_options [pretty: false, doctype: false, iodata: false]

  @spec to_html(input :: keyword(), options :: keyword()) :: String.t()
  @doc ~S"""
  Converts a tuple into an HTML string

  ## Options:

  - `pretty`: Passing `true` causes the HTML output to be pretty-printed. Defaults to `false`.
  - `doctype`: Prepend the `<!DOCTYPE html>` to the resulting string. Defaults to `false`.
  - `iodata`: Return the HTML as iodata. Defaults to `false`.

  ## Syntax:

  A tuple begining with an atom represents an HTML element:

      iex> {:div} |> Pile.to_html()
      "<div></div>"

  Elements can have children:
      
      iex> {:div, {:p}, {:p}} |> Pile.to_html()
      "<div><p></p><p></p></div>"

  Lists are automatically flattened, which is particularly useful for iteration & composition:

      iex> {:div, 
      ...>   {:p},
      ...>   1..2 |> Enum.map(fn _ -> {:span} end)
      ...> } |> Pile.to_html()
      "<div><p></p><span></span><span></span></div>"

  Strings are HTML-escaped, then rendered as text:
      
      iex> {:div, "hello"} |> Pile.to_html()
      "<div>hello</div>"
      iex> {:div, "<span>"} |> Pile.to_html()
      "<div>&lt;span&gt;</div>"

  To bypass HTML escaping, using the special `_rawtext` element:
      
      iex> {:div, {:_rawtext, "<span>"}} |> Pile.to_html()
      "<div><span></div>"

  Elements may have attributes. These are represented as a map, and if present must come right after the element name:

      iex> {:div, %{class: "container"}} |> Pile.to_html()
      "<div class=\"container\"></div>"
      iex> {:div, %{class: "container"}, "foo", {:p}} |> Pile.to_html()
      "<div class=\"container\">foo<p></p></div>"

  An attribute with a boolean value is treated as an [HTML boolean attribute](https://developer.mozilla.org/en-US/docs/Glossary/Boolean/HTML)

      iex> {:div, %{readonly: true}} |> Pile.to_html()
      "<div readonly></div>"
      iex> {:div, %{readonly: false}} |> Pile.to_html()
      "<div></div>"
  """
  def to_html(tuple, opts \\ @default_options) when is_tuple(tuple) do
    opts = Keyword.validate!(opts, @default_options)

    normalized = Pile.Normalize.run(tuple)

    html = Pile.Visitor.traverse(normalized, Pile.Visitor.Serializer, opts)

    html =
      if opts[:doctype] do
        ["<!DOCTYPE html>" | html]
      else
        html
      end

    if opts[:iodata] do
      html
    else
      IO.iodata_to_binary(html)
    end
  end
end
