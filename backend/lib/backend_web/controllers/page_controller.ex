defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  alias BackendWeb.Helpers.Auth

  def index(conn, _params) do
    # If the user is not logged in, redirect to the login page.
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil -> redirect(conn, to: Routes.session_path(conn, :new))
      user_id -> 
        user = Auth.current_user(conn)
        conn
        |> render("index.html",
          logs: Backend.Logs.get_logs_for_user(user)
        )
    end
  end
end
