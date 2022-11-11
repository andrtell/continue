defmodule Continue.Runner do
  use GenServer

  alias Continue.Git
  alias Continue.Podman
  alias Continue.Terminal

  # API 

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: Continue.Runner)
  end

  def build(url, tags) do
    GenServer.cast(Continue.Runner, {:build, url, tags})
  end

  # OTP

  @impl true
  def init(_args) do
    state = 42
    {:ok, state}
  end

  @impl true
  def handle_cast({:build, url, tags}, state) do
    Terminal.broadcast("\n==== Start build ====\n\n")
    tmp_dir = Continue.File.mktemp!()
    Git.clone!(url, tmp_dir)
    Podman.build!(tmp_dir, tags)
    Podman.push!(tags)
    Podman.image_rm!(tags)
    File.rm_rf!(tmp_dir)
    {:noreply, :ok, state}
  end

end
