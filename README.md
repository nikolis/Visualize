# Visualize

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

The tought behind seperating the two different "pages" of the requirements into 2 different live-views in a different session is because the approach for calculating the "current" page the user is currently browsing at in order for the navigation to work was inspired from the https://github.com/fly-apps/live_beats/tree/master. 

