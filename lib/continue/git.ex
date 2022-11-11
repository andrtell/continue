defmodule Continue.Git do
  alias Continue.Terminal

  def clone!(url, directory) do
    {_, 0} =
      System.cmd(
        "git",
        ["clone", url, directory],
        stderr_to_stdout: true,
        into: Terminal.new()
      )
  end
end
