defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  alias Backend.Logs
  alias BackendWeb.Helpers.Auth

  def index(conn, _params) do
    # If the user is not logged in, redirect to the login page.
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil -> redirect(conn, to: Routes.session_path(conn, :new))
      user_id -> 
        logs = Logs.get_log_messages_for_user_id(user_id)
        render(conn, "index.html", logs: logs)
    end
  end
end
