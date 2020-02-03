defmodule Herb do
  @moduledoc """
  Documentation for `Herb`.
  """

  def main(args \\ []) do
    IO.inspect({:args, args})
    IO.puts("Herb doesn't actually work yet, coming soon…")
    exit({:shutdown, 1})
  end
end
