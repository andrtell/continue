defmodule Continue.File do
  def mktemp!() do
    {tmp_dir, 0} = System.cmd("mktemp", [])
    tmp_dir
  end
end
