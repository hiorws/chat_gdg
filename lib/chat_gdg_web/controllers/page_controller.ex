defmodule ChatGdgWeb.PageController do
  use ChatGdgWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
