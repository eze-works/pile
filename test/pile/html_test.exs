defmodule Pile.HtmlTest do
  use ExUnit.Case, async: true
  import Pile.Html, only: [to_html: 2, to_html: 1]

  test "fails to print with unrecognized options" do
    assert_raise ArgumentError, fn ->
      [] |> to_html(what: true)
    end
  end

  test "html escape regular text" do
    html = [_text: ~S/<'ole &"foo>/] |> to_html()
    assert html == "&lt;&#39;ole &amp;&quot;foo&gt;"
  end

  test "leaves raw text as is" do
    html = [_rawtext: ~S/<'ole &"foo>/] |> to_html()
    assert html == ~S/<'ole &"foo>/
  end

  test "keyword values must be lists" do
    assert_raise FunctionClauseError, fn ->
      [div: 4] |> to_html()
    end
  end

  test "First value in keyword list must be either a tuple or a map" do
    assert_raise ArgumentError, ~r/Expected tuple or map/, fn ->
      [div: ["blah"]] |> to_html()
    end
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
      button: [%{active: false}]
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
end
