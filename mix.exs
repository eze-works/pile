defmodule Pile.MixProject do
  use Mix.Project

  def project do
    [
      app: :pile,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: [
        extras: ["README.md"]
      ]
    ]
  end


  def cli do
    [preferred_envs: [t: :test]]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp aliases do
    [
      t: "test --trace"
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end
