# ChatGdg - GDG Izmir 2017

A real-time chat application using websockets written in Elixir Phoenix Web Framework

To start finished version of the sample application written in this tutorial:

* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Install Node.js dependencies with `cd assets && npm install`
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

----

- [ChatGdg - GDG Izmir 2017](#chatgdg---gdg-izmir-2017)
    - [Installing Requirements and Setting Up Development Environment](#installing-requirements-and-setting-up-development-environment)
        - [Erlang 18 or later](#erlang-18-or-later)
        - [Elixir 1.4 or later](#elixir-14-or-later)
        - [Phoenix](#phoenix)
        - [node.js (>= 5.0.0)](#nodejs-500)
        - [PostgreSQL](#postgresql)
        - [inotify-tools (for linux users)](#inotify-tools-for-linux-users)
    - [Creating skeleton of a phoenix application with mix](#creating-skeleton-of-a-phoenix-application-with-mix)
        - [Setting Configuration File](#setting-configuration-file)
    - [Editing homepage](#editing-homepage)
    - [Using Presence Module and Activating Channels](#using-presence-module-and-activating-channels)
        - [Generating Presence Module](#generating-presence-module)
        - [Activating Channels](#activating-channels)
    - [Creating the Database Schema (not Model!)](#creating-the-database-schema-not-model)
        - [Insert a sample data from iex shell](#insert-a-sample-data-from-iex-shell)
    - [Generating UserController and UserView](#generating-usercontroller-and-userview)
        - [Usage of Resources](#usage-of-resources)
        - [Controller](#controller)
        - [View](#view)
    - [CRUD Operations](#crud-operations)
        - [Create a User](#create-a-user)
        - [Update and Delete](#update-and-delete)
    - [Hash the Password](#hash-the-password)
    - [User Authentication](#user-authentication)
        - [Using Guardian as an Authenticator](#using-guardian-as-an-authenticator)
        - [Editing Router](#editing-router)
        - [Tokens](#tokens)
        - [Sessions](#sessions)
    - [User Restrictions](#user-restrictions)
    - [Changing Layout](#changing-layout)
        - [Generate a Helper Function](#generate-a-helper-function)
        - [Show Username in the Chat Page](#show-username-in-the-chat-page)
        - [Entering Chat Room](#entering-chat-room)
    - [Additional Source](#additional-source)

Table of Contents

## Installing Requirements and Setting Up Development Environment

Follow the instructions.

### Erlang 18 or later

When we install Elixir using instructions from the Elixir [Installation Page](https://elixir-lang.org/install.html), we will usually get Erlang too. If Erlang was not installed along with Elixir, please see the [Erlang Instructions](https://elixir-lang.org/install.html#installing-erlang) section of the Elixir Installation Page for instructions.

### Elixir 1.4 or later

**Mac OS X**
Macports
Run: sudo port install elixir

**Homebrew**
Update your homebrew to latest: brew update
Run: brew install elixir

### Phoenix

```bash
mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez
```

### node.js (>= 5.0.0)

Install from the [link.](https://nodejs.org/en/download/)

### PostgreSQL

Install from the [link.](https://www.postgresql.org/download/)

### inotify-tools (for linux users)

For Ubuntu 14.04/16.04

```bash
sudo apt-get install inotify-tool
```

For other distros download from [here](https://github.com/rvoicilas/inotify-tools/wiki)

Links taken from [installation docs](https://hexdocs.pm/phoenix/installation.html#content)

## Creating skeleton of a phoenix application with mix

```bash
mix phx.new chat_gdg
```

Press y and enter to fetch and install dependencies

Then the output should be:

```bash
* creating chat_gdg/assets/css/app.css
* creating chat_gdg/assets/css/phoenix.css
* creating chat_gdg/assets/js/app.js
* creating chat_gdg/assets/js/socket.js
* creating chat_gdg/assets/package.json
* creating chat_gdg/assets/static/robots.txt
* creating chat_gdg/assets/static/images/phoenix.png
* creating chat_gdg/assets/static/favicon.ico

Fetch and install dependencies? [Yn] Y
* running mix deps.get
* running mix deps.compile
* running cd assets && npm install && node node_modules/brunch/bin/brunch build

We are all set! Go into your application by running:

    $ cd chat_gdg

Then configure your database in config/dev.exs and run:

    $ mix ecto.create

Start your Phoenix app with:

    $ mix phx.server

You can also run your app inside IEx (Interactive Elixir) as:

    $ iex -S mix phx.server
```

### Setting Configuration File

Open the **chat_gdg/config/dev.exs** file with a text editor and set the database credentials.
Example:

```elixir
# Configure your database
config :chat_gdg, ChatGdg.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "chat_gdg_dev",
  hostname: "localhost",
  pool_size: 10
```

Make sure database application is up and run these commands to fire up:

```bash
cd chat_gdg
mix ecto create
mix phx.server
```

Take a look at the application structure.

A simple hello world application is ready.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Editing homepage

Take a look at the **router.ex**

In **lib/chat_gdg_web/router.ex**

```elixir
  scope "/", ChatGdgWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
```

`get "/", PageController, :index` this line directs the **Page Controller**
Now check the **Page Controller**

```elixir
defmodule ChatGdgWeb.PageController do
  use ChatGdgWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
```

In the **Page Controller** the **index** function renders the **index.html** template.

Let's edit the lib/chat_gdg_web/templates/page/index.html.eex as:

```html
<div class="row">
  <div class="col-md-12 alert alert-info">
    Hello, <span id="User"><%= @conn.params["user"] %></span>!
  </div>
  <div class="col-md-8">
    <h2>Messages:</h2>
    <ul id="MessageList" class="list-unstyled" style="height: 400px; border: 1px solid black; overflow-y: auto; padding: 10px;" ></ul>
    <input type="text" id="NewMessage" class="form-control">
  </div>
  <div  class="col-md-4">
    <h2>Who’s Online</h2>
    <ul id="UserList" class="list-unstyled">
      <li>Loading online users...</li>
    </ul>
  </div>
</div>
```

Again visit [`localhost:4000`](http://localhost:4000) from your browser.

And [`http://0.0.0.0:4000/?user=joearms`](http://0.0.0.0:4000/?user=joearms)

In the index.html.eex `Hello, <span id="User"><%= @conn.params["user"] %></span>!` line the `@conn.params["user"]` shows us the user from the connection's query parameters.

## Using Presence Module and Activating Channels

[Presence Doc](https://hexdocs.pm/phoenix/Phoenix.Presence.html)

[Channels Doc](https://hexdocs.pm/phoenix/channels.html)

### Generating Presence Module

We will use the Presence module to track users status (is online & online since)

Provides Presence tracking to processes and channels.

This behaviour provides presence features such as fetching presences for a given topic, as well as handling diffs of join and leave events as they occur in real-time. Using this module defines a supervisor and allows the calling module to implement the Phoenix.Tracker behaviour which starts a tracker process to handle presence information.

To create our presence with this command:

```bash
mix phx.gen.presence
```

output

```bash
* creating lib/chat_gdg_web/channels/presence.ex

Add your new module to your supervision tree,
in lib/chat_gdg/application.ex:

    children = [
      ...
      supervisor(ChatGdgWeb.Presence, []),
    ]

You're all set! See the Phoenix.Presence docs for more details:
http://hexdocs.pm/phoenix/Phoenix.Presence.html
```

### Activating Channels

Let's activate the channel to use websockets:

Uncomment the this line in the **lib/chat_gdg_web/channels/user_socket.ex**

```elixir
channel "room:*", ChatGdgWeb.RoomChannel
```

and edit the **connect** function:

```elixir
def connect(%{"user" => user}, socket) do
    {:ok, assign(socket, :user, user)}
end
```

Then create a module to handle room channel:
Create a file named **room_channel.ex** under **lib/chat_gdg_web/channels**

```elixir
defmodule ChatGdg.RoomChannel do
    use ChatGdg.Web, :channel
    alias ChatGdg.Presence

    def join("room:lobby", _, socket) do
      send self(), :after_join
      {:ok, socket}
    end

    def handle_info(:after_join, socket) do
      Presence.track(socket, socket.assigns.user, %{
        online_at: :os.system_time(:milli_seconds)
      })
      push socket, "presence_state", Presence.list(socket)
      {:noreply, socket}
    end

    def connect(%{"user" => user}, socket) do
      {:ok, assign(socket, :user, user)}
    end

end
```

Modify the **app.js** file under the **assets/js/** such as:

```javascript
import "phoenix_html"
import {Socket, Presence} from "phoenix"

// get the user element from index.html
let user = document.getElementById("User").innerText

// generate a socket connection with the user parameter
let socket = new Socket("/socket", {params: {user: user}})
socket.connect()

// create an empty js object to handle presences
let presences = {}

let formatTimestamp = (timestamp) => {
  let date = new Date(timestamp)
  return date.toLocaleTimeString()
}
let listBy = (user, {metas: metas}) => {
  return {
    user: user,
    onlineAt: formatTimestamp(metas[0].online_at)
  }
}

// get the UserList element from index.html
let userList = document.getElementById("UserList")
let render = (presences) => {
  userList.innerHTML = Presence.list(presences, listBy)
    .map(presence => `
      <li>
        <b>${presence.user}</b>
        <br><small>online since ${presence.onlineAt}</small>
      </li>
    `)
    .join("")
}

// handle with the single channel
// create a connection between client and room:lobby channel and set the presences settings
let room = socket.channel("room:lobby", {})
room.on("presence_state", state => {
  presences = Presence.syncState(presences, state)
  render(presences)
})

room.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff)
  render(presences)
})

// join the room
room.join()

// get the NewMessage element from index.html
let messageInput = document.getElementById("NewMessage")
messageInput.addEventListener("keypress", (e) => {
  if (e.keyCode == 13 && messageInput.value != "") {
    room.push("message:new", messageInput.value)
    messageInput.value = ""
  }
})

let messageList = document.getElementById("MessageList")
let renderMessage = (message) => {
  let messageElement = document.createElement("li")
  messageElement.innerHTML = `
    <b>${message.user}</b>
    <i>${formatTimestamp(message.timestamp)}</i>
    <p>${message.body}</p>
  `
  messageList.appendChild(messageElement)
  messageList.scrollTop = messageList.scrollHeight;
}

room.on("message:new", message => renderMessage(message))
```

## Creating the Database Schema (not Model!)

```bash
mix phx.gen.schema User users email:unique encrypt_pass:string
```

output:

```bash
* creating lib/chat_gdg/user.ex
* creating priv/repo/migrations/20171201161350_create_users.exs

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```

take a look at model file and migration file:

```bash
cat priv/repo/migrations/20171201161350_create_users.exs
```

```elixir
defmodule ChatGdg.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :encrypt_pass, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
```

```bash
cat lib/chat_gdg/user.ex
```

```elixir
defmodule ChatGdg.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatGdg.User


  schema "users" do
    field :email, :string
    field :encrypt_pass, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :encrypt_pass])
    |> validate_required([:email, :encrypt_pass])
    |> unique_constraint(:email)
  end
end
```

Add a field line for real(!) password but not store with the functionality of virtual parameter

```elixir
  schema "users" do
    field :email, :string
    field :encrypt_pass, :string
    field :password, :string, virtual: true

    timestamps()
  end
```

and edit the changeset function as below

```elixir
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
  end
```

[Take a look]('https://hexdocs.pm/ecto/Ecto.Schema.html#field/3') at usage of virtual field in Ecto schema

Then apply the migration with the mix command

```bash
mix ecto.migrate
```

output:

```bash
Compiling 1 file (.ex)
Generated chat_gdg app
[info] == Running ChatGdg.Repo.Migrations.CreateUsers.change/0 forward
[info] create table users
[info] create index users_email_index
[info] == Migrated in 0.0s
```

### Insert a sample data from iex shell

```bash
iex -S mix phx.server
Erlang/OTP 19 [erts-8.3] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

[info] Running ChatGdgWeb.Endpoint with Cowboy using http://0.0.0.0:4000
Interactive Elixir (1.4.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 19:46:54 - info: compiled 6 files into 2 files, copied 3 in 914 ms
alias ChatGdg.Repo
ChatGdg.Repo
iex(2)> alias ChatGdg.User
ChatGdg.User
iex(3)> Repo.all(User)
[debug] QUERY OK source="users" db=1.7ms queue=0.1ms
SELECT u0."id", u0."email", u0."encrypt_pass", u0."inserted_at", u0."updated_at" FROM "users" AS u0 []
[]
iex(4)> Repo.insert(%User{email: "joearms@erlang.com", encrypt_pass: "password"})
[debug] QUERY OK db=7.8ms
INSERT INTO "users" ("email","encrypt_pass","inserted_at","updated_at") VALUES ($1,$2,$3,$4) RETURNING "id" ["joearms@erlang.com", "password", {{2017, 12, 1}, {16, 49, 29, 841382}}, {{2017, 12, 1}, {16, 49, 29, 843639}}]
{:ok,
 %ChatGdg.User{__meta__: #Ecto.Schema.Metadata<:loaded, "users">,
  email: "joearms@erlang.com", encrypt_pass: "password", id: 1,
  inserted_at: ~N[2017-12-01 16:49:29.841382], password: nil,
  updated_at: ~N[2017-12-01 16:49:29.843639]}}
```

## Generating UserController and UserView

### Usage of Resources

To handle CRUD operations add **UserController** the **router.ex** with [resources](https://hexdocs.pm/phoenix/routing.html#resources) macro.

```elixir
  scope "/", ChatGdgWeb do
    pipe_through :browser # Use the default browser stack
    resources "/users", UserController
    get "/", PageController, :index
  end
```

then check our new routes with the command:

```bash
mix phx.routes
Compiling 1 file (.ex)
user_path  GET     /users           ChatGdgWeb.UserController :index
user_path  GET     /users/:id/edit  ChatGdgWeb.UserController :edit
user_path  GET     /users/new       ChatGdgWeb.UserController :new
user_path  GET     /users/:id       ChatGdgWeb.UserController :show
user_path  POST    /users           ChatGdgWeb.UserController :create
user_path  PATCH   /users/:id       ChatGdgWeb.UserController :update
           PUT     /users/:id       ChatGdgWeb.UserController :update
user_path  DELETE  /users/:id       ChatGdgWeb.UserController :delete
page_path  GET     /                ChatGdgWeb.PageController :index
```

### Controller

Create the skeleton of **user_controller.ex** at **lib/chat_gdg_web/controllers/**

```elixir
defmodule ChatGdgWeb.UserController do
    use ChatGdgWeb, :controller

    alias ChatGdg.User
    alias ChatGdg.Repo

    def index(conn, _params) do
        users = Repo.all(User)
        render(conn, "index.html", users: users)
    end

    def show(conn, %{"id" => id}) do
        user = Repo.get!(User, id)
        render(conn, "show.html", user: user)
    end
end
```

### View

And create the **user_view.ex** at **lib/chat_gdg_web/views/**

```elixir
defmodule ChatGdgWeb.UserView do
    use ChatGdgWeb, :view
end
```

And finally create the **index.html.eex** at **lib/chat_gdg_web/templates/user/**

```html
<h2>List of users</h2>

<table class="table">
  <thead>
    <tr>
      <th>Email</th>

      <th></th>
    </tr>
  </thead>
  <tbody>
<%= for user <- @users do %>
    <tr>
      <td><%= user.email %></td>
      <td class="text-right">
        <%= link "Profile", to: user_path(@conn, :show, user), class: "btn btn-default btn-xs" %>
        <%= link "Edit", to: user_path(@conn, :edit, user), class: "btn btn-default btn-xs" %>
        <%= link "Delete User", to: user_path(@conn, :delete, user), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %>

      </td>
    </tr>

<% end %>
  </tbody>
</table>


<%= link "New user", to: user_path(@conn, :new) %>
```

Now visit [`localhost:4000/users`](http://localhost:4000/users) from your browser and try the Profile button!

*If you try to click **Edit** or **Delete User** buttons you will get error because we did not define new-create, edit-update and delete functions!*

## CRUD Operations

### Create a User

To create a user we need to add **new** and **create** functions in the our controller. Add these functions to **user_controller.ex**

```elixir
    def new(conn, _params) do
        changeset = User.changeset(%User{})
        render(conn, "new.html", changeset: changeset)
    end

    def create(conn, %{"user" => user_params}) do
        changeset = User.reg_changeset(%User{}, user_params)
        case Repo.insert(changeset) do
        {:ok, _user} ->
            conn
            |> put_flash(:info, "User created successfully.")
            |> redirect(to: user_path(conn, :index))
        {:error, changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
    end
```

Then create a **new.html.eex** and **form.html.eex** template. **form.html.eex** will be inherited and handle in create and edit operations.

new.html.eex

```html
<h2>Create a new User</h2>

<%= render "form.html", changeset: @changeset,
                        action: user_path(@conn, :create) %>

<%= link "Back", to: user_path(@conn, :index) %>
```

form.html.eex

```html
<%= form_for @changeset, @action, fn f -> %>
  <%= if @changeset.action do %>
    <div class="alert alert-danger">
      <p>Oops, something went wrong! Please check the errors below.</p>
    </div>
  <% end %>

  <div class="form-group">
    <%= label f, :email, class: "control-label" %>
    <%= email_input f, :email, class: "form-control" %>
    <%= error_tag f, :email %>
  </div>

  <div class="form-group">
    <%= label f, :password, class: "control-label" %>
    <%= password_input f, :password, class: "form-control" %>
    <%= error_tag f, :password %>
  </div>

  <div class="form-group">
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>
<% end %>
```

Now try to create a user:

[http://0.0.0.0:4000/users/new](http://0.0.0.0:4000/users/new)

### Update and Delete

To handle update and delete operations -as usual we did- now we will implement the **edit**, **update** and **delete** function to the **user_controller.ex**

```elixir
    def edit(conn, %{"id" => id}) do
        user = Repo.get!(User, id)
        changeset = User.changeset(user)
        render(conn, "edit.html", user: user, changeset: changeset)
    end

    def update(conn, %{"id" => id, "user" => user_params}) do
        user = Repo.get!(User, id)
        changeset = User.changeset(user, user_params)

        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: user_path(conn, :show, user))
          {:error, changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end
    end

    def delete(conn, %{"id" => id}) do
        user = Repo.get!(User, id)
        Repo.delete!(user)

        conn
        |> put_flash(:danger, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))
    end
```

And create and **edit.html.eex** template for editing user page.

edit.html.eex

```html
<h2>Edit user</h2>

<%= render "form.html", changeset: @changeset,
                        action: user_path(@conn, :update, @user) %>

<%= link "Back", to: user_path(@conn, :index) %>
```

Now we able to use create, read, update and delete functions/operations.

## Hash the Password

Do not store passwords in plain text. Are you asking why? Then check [this](http://plaintextoffenders.com/about/) out.

We need some functions, then we will search for a Elixir hashing library. Let's search a package from [hex.pm](https://hex.pm/)

Search for 'hash' then inspect the results.

Let's use [comeonin](https://hex.pm/packages/comeonin).

Copy the `{:comeonin, "~> 3.0"}` dependency and paste it to **mix.exs**. Your **mix.exs** file should be like this:

```elixir
defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0"}
    ]
  end
```

Then, get the dependencies and compile:

```bash
mix deps.get
```

Output:

```bash
Resolving Hex dependencies...
Dependency resolution completed:
  comeonin 3.2.0
  connection 1.0.4
  cowboy 1.1.2
  cowlib 1.0.2
  db_connection 1.1.2
  decimal 1.4.1
  ecto 2.2.6
  file_system 0.2.2
  gettext 0.13.1
  mime 1.1.0
  phoenix 1.3.0
  phoenix_ecto 3.3.0
  phoenix_html 2.10.5
  phoenix_live_reload 1.1.3
  phoenix_pubsub 1.0.2
  plug 1.4.3
  poison 3.1.0
  poolboy 1.5.1
  postgrex 0.13.3
  ranch 1.3.2
* Getting comeonin (Hex package)
  Checking package (https://repo.hex.pm/tarballs/comeonin-4.0.3.tar)
  Fetched package
```

```bash
mix deps.compile
```

Output:

```bash
===> Compiling ranch
===> Compiling poolboy
==> comeonin
Compiling 2 files (.ex)
Generated comeonin app
===> Compiling cowlib
===> Compiling cowboy
```

Now we can use the comeonin library in our application.

Let's and add two function which handles hashing password to the **user.ex**

```elixir

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
```

Then edit **create** and **update** in the **user_controller.ex** to use our new **reg_changeset** function.

```elixir
    def create(conn, %{"user" => user_params}) do
        changeset = User.reg_changeset(%User{}, user_params)
        case Repo.insert(changeset) do
        {:ok, _user} ->
            conn
            |> put_flash(:info, "User created successfully.")
            |> redirect(to: user_path(conn, :index))
        {:error, changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
    end

```

```elixir
    def update(conn, %{"id" => id, "user" => user_params}) do
        user = Repo.get!(User, id)
        changeset = User.reg_changeset(user, user_params)

        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: user_path(conn, :show, user))
          {:error, changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end
    end

```

## User Authentication

### Using Guardian as an Authenticator

We will use [Guardian](https://github.com/ueberauth/guardian) library to handle authentication in our application.

*Guardian is a token based authentication library for use with Elixir applications.

Guardian remains a functional system. It integrates with Plug, but can be used outside of it. If you're implementing a TCP/UDP protocol directly, or want to utilize your authentication via channels in Phoenix, Guardian is your friend.*

Let's add the dependency to **mix.exs**

```elixir
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0"},
      {:guardian, "~> 0.14"}
    ]
  end
```

```bash
mix deps.get
```

Output:

```bash
Resolving Hex dependencies...
Dependency resolution completed:
  base64url 0.0.1
  comeonin 3.2.0
  connection 1.0.4
  cowboy 1.1.2
  cowlib 1.0.2
  db_connection 1.1.2
  decimal 1.4.1
  ecto 2.2.6
  elixir_make 0.4.0
  file_system 0.2.2
  gettext 0.13.1
  guardian 0.14.5
  jose 1.8.4
  mime 1.1.0
  phoenix 1.3.0
  phoenix_ecto 3.3.0
  phoenix_html 2.10.5
  phoenix_live_reload 1.1.3
  phoenix_pubsub 1.0.2
  plug 1.4.3
  poison 3.1.0
  poolboy 1.5.1
  postgrex 0.13.3
  ranch 1.3.2
  uuid 1.1.8
* Getting guardian (Hex package)
  Checking package (https://repo.hex.pm/tarballs/guardian-0.14.5.tar)
  Using locally cached package
* Getting jose (Hex package)
  Checking package (https://repo.hex.pm/tarballs/jose-1.8.4.tar)
  Using locally cached package
* Getting uuid (Hex package)
  Checking package (https://repo.hex.pm/tarballs/uuid-1.1.8.tar)
  Using locally cached package
* Getting base64url (Hex package)
  Checking package (https://repo.hex.pm/tarballs/base64url-0.0.1.tar)
  Using locally cached package
```

```bash
mix deps.compile
```

```bash
===> Compiling base64url
==> jose
Compiling 89 files (.erl)
Compiling 8 files (.ex)
Generated jose app
===> Compiling ranch
==> poolboy (compile)
==> comeonin
make: Nothing to be done for `all'.
===> Compiling cowlib
===> Compiling cowboy
==> uuid
Compiling 1 file (.ex)
Generated uuid app
==> guardian
Compiling 21 files (.ex)
Generated guardian app
```

Then add the configuration parameters block to **config/config.exs**

```elixir

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT, # optional
  issuer: "ChatGdg",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "dY3otygFOMcX1zXEwQ11JFIQdZp0Z+C0xEF1lx5gOpef/mYrsWu28dW++FBvm7qi",
  serializer: ChatGdg.GuardianSerializer
```

You can generate a secret key with the command:

```bash
mix phx.gen.secret
```

Ouput:

```bash
dY3otygFOMcX1zXEwQ11JFIQdZp0Z+C0xEF1lx5gOpef/mYrsWu28dW++FBvm7qi
```

Put it to **secret_key** parameter.

Now create a Guardian controller. Put it to **chat_gdg/controller/guardian_serializer.ex**

```elixir
defmodule ChatGdg.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias ChatGdg.Repo
  alias ChatGdg.User

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, Repo.get(User, id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
```

### Editing Router

Now here is the **Plug** rocks!

Modify the **router.ex** to handle authentication with Guardian and sessions, then our **router.ex** should be like that:

```elixir
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
```

### Tokens

Let's create token handler **token.ex**:

```elixir
defmodule ChatGdg.Token do
    use ChatGdgWeb, :controller

    def unauthenticated(conn, _params) do
        conn
        |> put_flash(:error, "You must be signed in!")
        |> redirect(to: session_path(conn, :new))
    end

    def unauthorized(conn, _params) do
        conn
        |> put_flash(:error, "You must be signed in!")
        |> redirect(to: session_path(conn, :new))
    end
end
```

### Sessions

And add **Session View** and **Session Controller**

Let's define a simple view, **session_view.ex**:

```elixir
defmodule ChatGdgWeb.SessionView do
    use ChatGdgWeb, :view
end
```

And our session controller, **session_controller.ex**:

```bash
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
```

Final step for handling sessions is creating the template.

chat_gdg_web/templates/sessions/new.html.eex:

```html
<h1>Sign In</h1>

<%= form_for @conn, session_path(@conn, :create), [as: :session], fn f -> %>
<div class="form-group">
  <%= label f, :email, class: "control-label" %>
    <%= email_input f, :email, class: "form-control" %>
    <%= error_tag f, :email %>
</div>

<div class="form-group">
    <%= label f, :password, class: "control-label" %>
    <%= password_input f, :password, class: "form-control" %>
    <%= error_tag f, :password %>
</div>

  <div class="form-group">
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>

<% end %>
```

## User Restrictions

To prevent the edit and delete operations without access we will implement user acces in the **user_controller.ex**

Edit the **edit**, **update** and **delete** functions as below:

```elixir
    def edit(conn, %{"id" => id}) do
        user = Repo.get!(User, id)
        cond do
        user == Guardian.Plug.current_resource(conn) ->
            changeset = User.changeset(user)
            render(conn, "edit.html", user: user, changeset: changeset)
        :error ->
            conn
            |> put_flash(:error, "No access")
            |> redirect(to: user_path(conn, :index))
        end
    end

    def update(conn, %{"id" => id, "user" => user_params}) do
        user = Repo.get!(User, id)
        changeset = User.reg_changeset(user, user_params)
        cond do
        user == Guardian.Plug.current_resource(conn) ->
            case Repo.update(changeset) do
            {:ok, user} ->
                conn
                |> put_flash(:info, "User updated successfully.")
                |> redirect(to: user_path(conn, :show, user))
            {:error, changeset} ->
                render(conn, "edit.html", user: user, changeset: changeset)
        end
            :error ->
            conn
            |> put_flash(:error, "No access")
            |> redirect(to: user_path(conn, :index))
        end
    end

    def delete(conn, %{"id" => id}) do
        user = Repo.get!(User, id)
        cond do
        user == Guardian.Plug.current_resource(conn) ->
            Repo.delete!(user)
            conn
            |> Guardian.Plug.sign_out
            |> put_flash(:danger, "User deleted successfully.")
            |> redirect(to: session_path(conn, :new))
        :error ->
            conn
            |> put_flash(:error, "No access")
            |> redirect(to: user_path(conn, :index))
        end
    end
```

## Changing Layout

Now let's modify the page layout according to user authentication.

### Generate a Helper Function

Create a **Helper View** under the views:

```elixir
defmodule ChatGdgWeb.ViewHelper do
    def current_user(conn), do: Guardian.Plug.current_resource(conn)
    def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  end
```

Allow access to Helper View, add the line `import ChatGdgWeb.ViewHelper` to **lib/chat_gdg_web.ex** file:

```elixir
def view do
    quote do
      use Phoenix.View, root: "lib/chat_gdg_web/templates",
                        namespace: ChatGdgWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ChatGdgWeb.Router.Helpers
      import ChatGdgWeb.ErrorHelpers
      import ChatGdgWeb.Gettext
      import ChatGdgWeb.ViewHelper
    end
  end
```

And create a file named **logged.html.eex** under **lib/chat_gdg_web/templates/layout**:

```html
<%= if logged_in?(@conn) do %>
  <%= link "Sign Out", to: session_path(@conn, :delete, :access),
    method: :delete, class: "btn btn-danger" %>
  <%= link "#{current_user(@conn).email}", to: user_path(@conn, :show, current_user(@conn)) %>

  <% else %>
  <%= link "Create an Account!", to: user_path(@conn, :new),
    class: "btn btn-info" %>
  <%= link "Sign in", to: session_path(@conn, :new),
      class: "btn btn-primary" %>
<% end %>
```

And to render it, modify the **app.html.eex** template add it inside the header tag:

```html
<header class="header">
  <nav role="navigation">
    <ul class="nav nav-pills pull-right">
      <li><%= render "logged.html", conn: @conn %></li>
    </ul>
  </nav>
  <span class="logo"></span>
</header>
```

### Show Username in the Chat Page

To show username (email in our design), use an embedded elixir function in the **templates/page/index.html.eex** file:

Change these lines:

```html
<div class="col-md-12 alert alert-info">
  Hello, <span id="User"><%= @conn.params["user"] %></span>!
</div>
```

with these:

```html
<div class="col-md-12 alert alert-info">
  Hello, <span id="User"><%= "#{current_user(@conn).email}" %></span>!
</div>
```

### Entering Chat Room

Now add these lines to the user index template:

templates/user/index.html.eex

```html
<%= link "New user", to: user_path(@conn, :new), class: "btn btn-info" %>

<%= if logged_in?(@conn) do %>
  <%= link "Chat", to: page_path(@conn, :index), class: "btn btn-success" %><br><br>
  <% else %>
<% end %>
```

## Additional Source

* [Phoenix Docs](https://hexdocs.pm/phoenix/Phoenix.html)
* [Phoenix Book](https://pragprog.com/book/phoenix/programming-phoenix)
* [Elixir Docs](https://elixir-lang.github.io/docs.html)
* [Elixir School](https://elixirschool.com/en/)
* [Elixir Forum](https://elixirforum.com/)
* [Getting Started with Elixir](https://elixir-lang.github.io/getting-started/introduction.html)
* [Getting Started with Erlang](http://erlang.org/doc/getting_started/users_guide.html)
* [Learn You Some Erlang](http://learnyousomeerlang.com/)

