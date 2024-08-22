defmodule Pile.HtmlTest do
  use ExUnit.Case, async: true
  import Pile.Html, only: [to_html: 2, to_html: 1]

  test "returns empty string when there is nothing to serialize" do
    assert [] |> to_html() == ""
  end

  test "fails to print with unrecognized options" do
    assert_raise ArgumentError, fn ->
      [div: []] |> to_html(what: true)
    end
  end

  test "html escapes regular text" do
    html = [_text: ~S(<'ole &"foo>)] |> to_html()
    assert html == "&lt;&#39;ole &amp;&quot;foo&gt;"

    html = [p: ~S(<'ole &"foo>)] |> to_html()
    assert html == "<p>&lt;&#39;ole &amp;&quot;foo&gt;</p>"
  end

  test "leaves raw text as is" do
    html = [_rawtext: ~S(<'ole &"foo>)] |> to_html()
    assert html == ~S(<'ole &"foo>)

    html = [style: ~S(<'ole &"foo>)] |> to_html()
    assert html == ~S(<style><'ole &"foo></style>)
  end

  test "first value in keyword list must be either a tuple or a map" do
    assert_raise ArgumentError, ~r/Expected tuple, map or string/, fn ->
      [div: ["blah"]] |> to_html()
    end
  end

  test "supports string children" do
    data = [p: "not a list"]
    assert data |> to_html() == "<p>not a list</p>"

    assert data |> to_html(indent: true) == """
           <p>
             not a list
           </p>
           """
  end

  test "void elements do not have children" do
    data = [img: [p: []]]
    assert data |> to_html() == "<img>"
    assert data |> to_html(indent: true) == "<img>\n"
  end

  test "regular elements may have children" do
    data = [div: [p: [], span: []]]

    assert data |> to_html() == "<div><p></p><span></span></div>"

    assert data |> to_html(indent: true) == """
           <div>
             <p>
             </p>
             <span>
             </span>
           </div>
           """
  end

  test "elements may have attributes" do
    data = [
      div: [%{class: "container"}],
      input: [%{readonly: true}],
      button: [%{active: false, async: nil}]
    ]

    assert data |> to_html() == ~S(<div class="container"></div><input readonly><button></button>)

    assert data |> to_html(indent: true) == ~S"""
           <div class="container">
           </div>
           <input readonly>
           <button>
           </button>
           """
  end

  test "using the css attribute" do
    css = Pile.css("background-color: black;")
    css2 = Pile.css("background-color: black;")

    data = [
      body: [
        div: [
          p: [
            %{css: css}
          ]
        ]
      ],
      img: [%{css: css2}]
    ]

    result = data |> to_html()
    dbg(result)
  end
end
