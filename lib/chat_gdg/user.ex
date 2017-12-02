defmodule ChatGdg.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatGdg.User


  schema "users" do
    field :email, :string
    field :encrypt_pass, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
  end

  def reg_changeset(%User{} = user, attrs \\ %{}) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password], [])
    |> validate_required(:password, min: 5)
    |> hash_pw()
  end

  defp hash_pw(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: p}} ->
        put_change(changeset, :encrypt_pass, Comeonin.Pbkdf2.hashpwsalt(p))

      _ ->
        changeset
    end
  end

end