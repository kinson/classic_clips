defmodule BigBeefWeb.RedirectPlug do
  import Plug.Conn, only: [halt: 1]

  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Phoenix.Controller.redirect(opts)
    |> halt()
  end
end
