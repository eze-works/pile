defmodule Pile.Ruleset do
  @type t :: %__MODULE__{
          name: String.t(),
          content: String.t()
        }
  defstruct name: "", content: ""

  def new(declaration_block) when is_binary(declaration_block) do
    name = "pile-style-#{:erlang.phash2(declaration_block)}"
    content = ".#{name} { #{declaration_block} }"

    %Pile.Ruleset{
      name: name,
      content: content
    }
  end
end
