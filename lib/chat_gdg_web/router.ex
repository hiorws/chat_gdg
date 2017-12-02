defmodule ChatGdgWeb.Router do
  use ChatGdgWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  # define a new pipeline (browser authentication) 
  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.EnsureAuthenticated, handler: ChatGdgWeb.Token
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatGdgWeb do
    pipe_through :browser
    
    # unauthorized users can only trig the new and create functions
    resources "/users", UserController, [:new, :create]

    # let's generate create and delete operations for sessions
    resources "/sessions", SessionController, only: [:create, :delete]

    # now we redirect the root path to SessionController to check users session
    get "/", SessionController, :new
  end

  # define a new pipeline which uses both :browser and :browser_auth for authenticated users
  scope "/", ChatGdgWeb do
    pipe_through [:browser, :browser_auth]

    # authenticated users can only trig the show, onde
    resources "/users", UserController, only: [:show, :index, :update]

    # in here we direct the authenticated users to chat screen with Page Controller
    get "/chat", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatGdgWeb do
  #   pipe_through :api
  # end
end
