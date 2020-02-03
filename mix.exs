defmodule Herb.MixProject do
  use Mix.Project

  def project do
    [
      app: :herb,
      version: "0.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      description: description(),
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/shareup/herb"
        }
      ]
    ]
  end

  def description do
    "Execute .exs scripts with the ability to depend on other mix projects (including hex packages) without setting up a project yourself."
  end

  def escript do
    [main_module: Herb]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
