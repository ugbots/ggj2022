defmodule Backend.Logs do
  alias Backend.Repo
  alias Backend.Logs.Log

  import Ecto.Query, only: [from: 2]

  def create_user_log(user, message) do
    %Log{}
    |> Log.changeset(%{
      user_id: user.id,
      message: message
    })
    |> Repo.insert
  end

  def get_logs_for_user(user) do
    query = from log in "logs",
      where: log.user_id == ^user.id,
      select: log.message,
      limit: 50
    Repo.all(query)
  end
end
