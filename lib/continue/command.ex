defmodule Continue.Command do
  alias Continue.Git
  alias Continue.Podman
  alias Continue.Terminal

  def build_and_push_to_registry!(url, tags) do
    Terminal.broadcast("== START ==\n")

    tmp_dir = Continue.File.mktemp!()
    Git.clone!(url, tmp_dir)

    case File.exists?(Path.join(tmp_dir, "Containerfile")) do
      true ->
        Podman.build!(tmp_dir, tags)
        Podman.push!(tags)
        Podman.image_rm!(tags)

      false ->
        Terminal.broadcast("No Containerfile found\n")
    end

    File.rm_rf!(tmp_dir)
    Terminal.broadcast("== END ==\n")
  end
end
