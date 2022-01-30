defmodule BackendWeb.UserController do
  use BackendWeb, :controller

  alias Backend.Accounts
  alias Backend.Accounts.User
  alias Backend.Game
  alias Backend.Logs

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    team = Enum.random(["green", "purple"])

    user_params = Map.put(user_params, "team", team)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Logs.create_user_log(user, "User " <> user.username <> " created.")

        case Game.create_inventory_for_user(user) do
          {:ok, _} ->
            Logs.create_user_log(user, "Inventory created.")

            conn
            |> put_session(:current_user_id, user.id)
            |> put_flash(:info, "Signed up successfully.")
            |> redirect(to: Routes.page_path(conn, :index))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
