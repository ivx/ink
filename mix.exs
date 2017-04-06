defmodule Ink.Mixfile do
  use Mix.Project

  def project do
    [app: :ink,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp description do
    """
    A backend for the Elixir Logger that logs JSON and can filter sensitive data.
    """
  end

  defp package do
    [name: :ink,
     files: ["lib",
             "mix.exs",
             "README*"],
     maintainers: ["Mario Mainz"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/ivx/ink"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:poison, "~> 3.1"},
     {:credo, "~> 0.7.0", only: [:dev, :test]},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
