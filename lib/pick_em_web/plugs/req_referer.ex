defmodule PickEmWeb.ReqReferer do
  use PickEmWeb, :controller

  require Logger

  def record(conn, _opts) do
    headers = Enum.into(conn.req_headers, %{}, fn {k, v} -> {k, v} end)

    request_path = conn.request_path || "no path"
    user_agent = Map.get(headers, "user-agent") || "no user-agent"
    referer = Map.get(headers, "referer") || "no referer"
    remote = Map.get(headers, "x-real-ip") || "no remote"

    Logger.notice("new conn: #{request_path} - #{remote} - #{referer} - #{user_agent}")
    conn
  end
end
