defmodule Vow.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      name: "Vow",
      app: :vow,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/keathley/vow",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
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
    Vow provides a system for Design by Contract in Elixir.
    """
  end

  def package do
    [
      name: "Vow",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/keathley/vow"}
    ]
  end

  def docs do
    [
      main: "Vow",
      source_ref: "v#{@version}",
      source_url: "https://github.com/keathley/vow"
    ]
  end
end
