defmodule Pile.MixProject do
  use Mix.Project

  def project do
    [
      app: :pile,
      version: "0.5.0",
      elixir: "~> 1.17",
      deps: deps(),
      description: "A library for generating HTML markup in Elixir",
      package: package(),
      source_url: "https://github.com/eze-works/pile"
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Source" => "https://github.com/eze-works/pile"}
    ]
  end
end
