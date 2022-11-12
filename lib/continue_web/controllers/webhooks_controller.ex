defmodule ContinueWeb.WebhooksController do
  use ContinueWeb, :controller

  require Logger

  alias Continue.Runner

  def github(%{assigns: %{github_signature_verified: true}} = conn, params) do
    [event] = get_req_header(conn, "x-github-event")
    handle_event(event, conn, params)
    json(conn, %{status: "ok"})
  end

  def github(conn, _params) do
    Logger.warn("Github event signature verification failed: #{inspect(conn.body_params)}")
    json(conn, %{status: "ok"})
  end

  defp handle_event(
         "push",
         %{
           body_params:
             %{
               "after" => _after_SHA,
               "ref" => "refs/heads/main",
               "deleted" => false,
               "repository" => %{
                 "url" => "https://github.com/andrtell/test-repo"
               }
             } = _body_params
         } = _conn,
         _params
       ) do
    Runner.run(Continue.Command, :build_and_push_to_registry!, [
      "https://github.com/andrtell/test-repo",
      ["registry.tell.nu/test-repo:latest"]
    ])
  end

  defp handle_event(
         "push",
         %{
           body_params:
             %{
               "after" => _after_SHA,
               "ref" => "refs/heads/main",
               "deleted" => false,
               "repository" => %{
                 "url" => "https://github.com/andrtell/continue"
               }
             } = _body_params
         } = _conn,
         _params
       ) do
    Runner.run(Continue.Command, :build_and_push_to_registry!, [
      "https://github.com/andrtell/continue",
      ["registry.tell.nu/continue:latest"]
    ])
  end

  defp handle_event(event, conn, _params) do
    Logger.warn("Github event (#{event}) ignored: #{inspect(conn.body_params)}")
  end
end
