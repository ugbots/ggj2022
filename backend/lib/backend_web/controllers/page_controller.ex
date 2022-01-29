defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  def index(conn, _params) do
    # If the user is not logged in, redirect to the login page.
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil -> redirect(conn, to: Routes.session_path(conn, :new))
      user -> render(conn, "index.html")
    end
  end
end
