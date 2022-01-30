defmodule BackendWeb.AttackController do
  use BackendWeb, :controller

  alias Backend.Game

  def attack(conn, %{"attack" => attack_params}) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    user = Backend.Repo.get(Backend.Accounts.User, user_id)

    Game.attack_username_from_user(
      user,
      Map.get(attack_params, "target"),
      Map.get(attack_params, "target_product"),
      Map.get(attack_params, "amount"),
      Map.get(attack_params, "product"))

    redirect(conn, to: Routes.page_path(conn, :index))
  end
end
