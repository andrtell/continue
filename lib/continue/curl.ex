defmodule Continue.Curl do
  alias Continue.Terminal

  def poke!(url) do
    {_, 0} =
      System.cmd(
        "curl",
        [url],
        stderr_to_stdout: true,
        into: Terminal.new()
      )
  end
end
