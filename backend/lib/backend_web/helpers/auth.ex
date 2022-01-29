defmodule BackendWeb.Helpers.Auth do

  def signed_in?(conn) do
    current_user(conn)
  end

  def current_user(conn) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    if user_id, do: Backend.Repo.get(Backend.Accounts.User, user_id)
  end

  def current_username(conn) do
    user = current_user(conn)
    if user, do: user.username
  end
end