defmodule ContinueWeb.Plugs.GithubSignatureVerifier do
  import Plug.Conn

  @sign_key "4WtXWQnHOnAEvc+zRvscisbuqqiNhTi5ls+FpR+tFFOSm26VU/TsvMFYd7qA+jF5"

  def init(default), do: default

  def call(conn, _default) do
    verified =
      case get_req_header(conn, "x-hub-signature-256") do
        [hub_signature_256] ->
          req_body = ContinueWeb.Plugs.CachingBodyReader.get_raw_body(conn)

          req_signature_256 =
            :crypto.mac(:hmac, :sha256, @sign_key, req_body)
            |> Base.encode16()
            |> String.downcase()

          hub_signature_256 == "sha256=#{req_signature_256}"

        _ ->
          false
      end

    assign(conn, :github_signature_verified, verified)
  end
end
