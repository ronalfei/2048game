-module(game_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	Procs = [
        {game, {game, start_link, []}, permanent, 5000, worker, dynamic}
    ],
	{ok, {{one_for_one, 1, 5}, Procs}}.
