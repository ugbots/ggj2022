defmodule BackendWeb.Helpers.Auth do

  def signed_in?(conn) do
    current_user(conn)
  end

  def current_user(conn) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    case user_id do
      nil -> nil
      user_id ->
        Backend.Repo.get(Backend.Accounts.User, user_id)
        |> Backend.Repo.preload(:inventory)
        |> Backend.Repo.preload(:logs)
    end 
  end

  def current_username(conn) do
    user = current_user(conn)
    if user, do: user.username
  end
end