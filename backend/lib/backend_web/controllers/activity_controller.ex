defmodule BackendWeb.ActivityController do
  use BackendWeb, :controller

  alias BackendWeb.Helpers.Auth
  alias Backend.Logs

  def set(conn, %{"activity" => activity}) do
    user = Auth.current_user(conn)

    Logs.create_user_log(user, "Changing activity to " <> activity)

    redirect(conn, to: Routes.page_path(conn, :index))
  end
end