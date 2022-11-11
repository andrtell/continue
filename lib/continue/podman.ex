defmodule Continue.Podman do
  alias Continue.Publisher

  def build!(directory, tags) do
    tag_map = Enum.flat_map(tags, fn tag -> ["-t", tag] end)

    {_, 0} =
      System.cmd(
        "podman",
        ["build", directory] ++ tag_map,
        stderr_to_stdout: true,
        into: Publisher.new("terminal")
      )
  end

  def push!([]), do: :ok

  def push!([tag | other_tags]) do
    {_, 0} =
      System.cmd(
        "podman",
        ["push", tag],
        stderr_to_stdout: true,
        into: Publisher.new("terminal")
      )

    push!(other_tags)
  end

  def image_rm!([]), do: :ok

  def image_rm!([tag | other_tags]) do
    {_, 0} =
      System.cmd(
        "podman",
        ["image", "rm", tag],
        stderr_to_stdout: true,
        into: Publisher.new("terminal")
      )

    image_rm!(other_tags)
  end

  def image_prune_all!() do
    {_, 0} =
      System.cmd(
        "podman",
        ["image", "prune", "-a"],
        stderr_to_stdout: true,
        into: Publisher.new("terminal")
      )
  end
end
