defmodule BackendWeb.SessionController do
  use BackendWeb, :controller

  alias Backend.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end


  def create(conn, %{"session" => auth_params}) do
    user = Accounts.get_by_username(auth_params["username"])

    case Comeonin.Bcrypt.check_pass(user, auth_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Logged in successfully.")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, err} ->
        conn
        |> put_flash(:error, "Credentials not found. Please try again.")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end