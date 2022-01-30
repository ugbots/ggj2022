defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  alias Backend.Logs

  def index(conn, _) do
    # If the user is not logged in, redirect to the login page.
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil ->
        redirect(conn, to: Routes.session_path(conn, :new))

      user_id ->
        logs = Logs.get_logs_for_user_id(user_id)
        render(conn, "index.html", logs: logs)
    end
  end

  def about(conn, _) do
    render(conn, "about.html")
  end
end
