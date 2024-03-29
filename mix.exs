defmodule Sysevents.Mixfile do
  use Mix.Project

  def project do
    [app: :sysevents,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :sqlite_ecto, :poison, :ecto, :cowboy, :plug],
     mod: {Sysevents, []}
    ]
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
      [{:cowboy, "~> 1.0.0"},
       {:plug, "~> 1.0"},
       {:sqlite_ecto, "~> 1.0.0"},
       {:ecto, "~> 1.0"},
       {:poison, "~> 1.5.2"}
      ]
  end
end
