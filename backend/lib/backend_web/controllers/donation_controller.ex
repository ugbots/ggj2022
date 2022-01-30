defmodule BackendWeb.DonationController do
  use BackendWeb, :controller
  alias Backend.Game

  def donate(conn, %{"donation" => donation_params}) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    user = Backend.Repo.get(Backend.Accounts.User, user_id)

    Game.donate_to_username_from_user(
      user, 
      Map.get(donation_params, "target"),
      Map.get(donation_params, "amount"),
      Map.get(donation_params, "product"))

    redirect(conn, to: Routes.page_path(conn, :index))
  end
end