defmodule Pile.Html do
  @default_options_to_html [indent: false]

  @spec to_html(input :: keyword(), options :: keyword()) :: String.t()
  @doc """
  Converts the HTML data structure to a string
  """
  def to_html(input, options \\ @default_options_to_html)
  def to_html([], _opts), do: ""

  def to_html([_ | _] = input, opts) do
    opts = Keyword.validate!(opts, @default_options_to_html)

    input
    |> Enum.map(fn node ->
      Pile.Html.Visitor.traverse(node, Pile.Html.Visitor.Serializer, opts)
    end)
    |> Enum.join("")
  end
end
