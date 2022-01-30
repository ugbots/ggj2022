defmodule BackendWeb.ShopController do
  use BackendWeb, :controller

  alias Backend.Game

  @spec buy(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def buy(conn, %{"product" => product}) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    user = Backend.Repo.get(Backend.Accounts.User, user_id)

    Game.buy_product_for_user(user, product)

    redirect(conn, to: Routes.page_path(conn, :index))
  end
end
