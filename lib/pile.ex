defmodule Pile do
  @default_options_to_html [indent: false]

  @spec to_html(input :: keyword(), options :: keyword()) :: String.t()
  @doc """
  Converts the HTML data structure to a string
  """
  def to_html(input, options \\ @default_options_to_html)
  def to_html([], _opts), do: ""

  def to_html([_ | _] = input, opts) do
    opts = Keyword.validate!(opts, @default_options_to_html)

    # Extract the paths to all the elements with a `css` attribute
    styled_paths =
      input
      |> Enum.flat_map(fn node ->
        Pile.Visitor.traverse(node, Pile.Visitor.StyleCollector, [])
      end)

    rulesets =
      styled_paths
      |> Enum.map(fn path -> get_in(input, path ++ [Access.at(0), :css]).content end)
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

    # Update the class attribute of elements with a `css` attrubte  
    input = Enum.reduce(styled_paths, input, &update_class_with_ruleset/2)

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

  defp update_class_with_ruleset(path, html) do
    class_path = path ++ [Access.at(0), Access.key(:class, "")]
    ruleset_path = path ++ [Access.at(0), :css]

    ruleset = get_in(html, ruleset_path)
    # Add the ruleset name to the class list
    html = update_in(html, class_path, fn existing -> "#{existing} #{ruleset.name}" end)
    # Ignore the `css` property while serializing by setting it to `false`
    update_in(html, ruleset_path, fn _ -> false end)
  end
end
