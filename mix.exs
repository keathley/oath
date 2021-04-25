defmodule Oath.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      name: "Oath",
      app: :oath,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/keathley/oath",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      env: [enable_contracts: false]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decorator, "~> 1.3"},

      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
    ]
  end

  defp description do
    """
    Oath provides a system for Design by Contract in Elixir.
    """
  end

  def package do
    [
      name: "oath",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/keathley/oath"}
    ]
  end

  def docs do
    [
      main: "Oath",
      source_ref: "v#{@version}",
      source_url: "https://github.com/keathley/oath"
    ]
  end
end
