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
    - [Create a User](#create-a-user)
    - [Update and Delete](#update-and-delete)

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
defmodule Chatter.RoomChannel do
    use Chatter.Web, :channel
    alias Chatter.Presence

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

## Create a User

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

## Update and Delete

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