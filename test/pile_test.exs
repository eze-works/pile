defmodule PileTest do
  use ExUnit.Case, async: true

  doctest(Pile)

  import Pile

  test "top-level input should be a keyword list" do
    assert_raise(ArgumentError, ~r/should be a keyword list/, fn ->
      [[], []] |> to_html() == ""
    end)
  end

  test "returns empty string when there is nothing to serialize" do
    assert [] |> to_html() == ""
  end

  test "empty string is discarded when used as value for element" do
    assert [div: [[], []]] |> to_html() == "<div></div>"
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

    html = [style: [_rawtext: ~S(<'ole &"foo>)]] |> to_html()
    assert html == ~S(<style><'ole &"foo></style>)
  end

  test "void elements do not have children" do
    data = [img: [p: []]]
    assert data |> to_html() == "<img>"
    assert data |> to_html(pretty: true) == "<img>\n"
  end

  test "void element matching is case insensitive" do
    data = [IMG: []]
    assert data |> to_html() == "<IMG>"
  end

  test "regular elements may have children" do
    data = [div: [p: [], span: []]]

    assert data |> to_html() == "<div><p></p><span></span></div>"

    assert data |> to_html(pretty: true) == """
           <div>
             <p>
             </p>
             <span>
             </span>
           </div>
           """
  end

  test "supports string children" do
    sample1 = [p: "string"]
    sample2 = [p: ["string"]]

    assert sample1 |> to_html() == "<p>string</p>"
    assert sample2 |> to_html() == "<p>string</p>"

    assert sample1 |> to_html(pretty: true) == """
           <p>
             string
           </p>
           """

    assert sample2 |> to_html(pretty: true) == """
           <p>
             string
           </p>
           """
  end

  test "supports attribute children" do
    sample1 = [p: %{class: "container"}]
    sample2 = [p: [%{class: "container"}]]

    assert sample1 |> to_html() == ~S(<p class="container"></p>)
    assert sample2 |> to_html() == ~S(<p class="container"></p>)

    assert sample1 |> to_html(pretty: true) == """
           <p class="container">
           </p>
           """

    assert sample2 |> to_html(pretty: true) == """
           <p class="container">
           </p>
           """
  end

  test "supports boolean attributes" do
    data = [
      input: [%{readonly: true}],
      button: [%{active: false, async: nil}]
    ]

    assert data |> to_html() == ~S(<input readonly><button></button>)

    assert data |> to_html(pretty: true) == ~S"""
           <input readonly>
           <button>
           </button>
           """
  end

  test "attribute ordering does not matter" do
    # Note how we loose the syntax sugar here
    html = [p: [{:span, []}, %{class: "container"}, {:p, []}]] |> to_html()
    assert html == ~S(<p class="container"><span></span><p></p></p>)
  end

  test "using the css attribute injects styles" do
    fragment = [p: [%{css: css("color: black;")}]]

    assert fragment |> to_html() ==
             ~S(<style>.pile-style-126328789 { color: black; }</style><p class="pile-style-126328789"></p>)

    full = [
      html: [head: [], p: [%{css: css("color: black;")}]]
    ]

    assert full |> to_html(pretty: true) == """
           <html>
             <head>
               <style>
                 .pile-style-126328789 { color: black; }
               </style>
             </head>
             <p class="pile-style-126328789">
             </p>
           </html>
           """
  end

  test "css attribute styles are de-duplicated" do
    data = [
      div: [
        span: [
          %{class: "card", css: css("color: black;")}
        ]
      ],
      img: [
        %{class: "image", css: css("color: black;")}
      ]
    ]

    assert data |> to_html(pretty: true) == """
           <style>
             .pile-style-126328789 { color: black; }
           </style>
           <div>
             <span class="card pile-style-126328789">
             </span>
           </div>
           <img class="image pile-style-126328789">
           """
  end
end
