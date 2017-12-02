defmodule ChatGdgWeb.SessionController do
    use ChatGdgWeb, :controller
    import ChatGdgWeb.Auth
    alias ChatGdg.Repo

    def new(conn, _params) do
        render(conn, "new.html")
    end

    def create(conn, %{"session" => %{"email" => user, "password" => password}}) do
	    case login_with(conn, user, password, repo: Repo) do
	    	{:ok, conn} ->
	    		logged_user = Guardian.Plug.current_resource(conn)
	    		conn 
	    		|> put_flash(:info, "logged in!")
	    		|> redirect(to: page_path(conn, :index))
	    	{:error, _reason, conn} ->
	    		conn
	    		|> put_flash(:error, "Wrong username/password")
	    		|> render("new.html")
	    end
    end

    def delete(conn, _) do
        conn
        |> Guardian.Plug.sign_out
        |> redirect(to: "/")
    end

end