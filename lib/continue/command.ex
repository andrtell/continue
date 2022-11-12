defmodule Continue.Command do
  alias Continue.Git
  alias Continue.Podman
  alias Continue.Curl
  alias Continue.Terminal

  def build_and_push_to_registry!(url, tags, hosts) do
    Terminal.broadcast("== START ==\n")

    Terminal.broadcast("== GIT ==\n")
    tmp_dir = Continue.File.mktemp!()
    Git.clone!(url, tmp_dir)

    case File.exists?(Path.join(tmp_dir, "Containerfile")) do
      true ->
        Terminal.broadcast("== BUILD ==\n")
        Podman.build!(tmp_dir, tags)
        Terminal.broadcast("== PUSH ==\n")
        Podman.push!(tags)
        Terminal.broadcast("== CLEAN ==\n")
        Podman.image_rm!(tags)
        #TODO: re-organize this
        Terminal.broadcast("== DEPLOY ==\n")
        Enum.each(hosts, fn host -> Curl.poke!("#{host}:9999/podman/auto-update") end)

      false ->
        Terminal.broadcast("No Containerfile found\n")
    end

    File.rm_rf!(tmp_dir)
    Terminal.broadcast("== END ==\n")
  end
end
