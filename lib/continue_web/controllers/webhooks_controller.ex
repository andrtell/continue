defmodule ContinueWeb.WebhooksController do
  use ContinueWeb, :controller

  require Logger

  def github(%{assigns: %{github_signature_verified: true}} = conn, params) do
    [event] = get_req_header(conn, "x-github-event")
    github_event(event, conn, params)
  end

  def github(_conn, _params) do
    Logger.warn("Github signature verification failed")
  end

  defp github_event(
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
         } = conn,
         _params
       ) do
    Logger.info("Github push event received for andrtell/test-repo")
    json(conn, %{status: "ok"})
  end

  defp github_event( "push", conn, _params) do
    Logger.warn("Push event not recognized: #{inspect(conn.body_params)}")
    json(conn, %{status: "ok"})
  end

end
