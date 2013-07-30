-module(erp_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    PoolArgs = [
        {name, {local, redis}},
        {worker_module, erp_worker},
        {size, get_env(size, 10)},
        {max_overflow, get_env(max_overflow, 20)}
    ],
    WorkerArgs = [
        {host, get_env(host, "127.0.0.1")},
        {port, get_env(port, 6379)}
    ],
    PoolSpec = poolboy:child_spec(redis, PoolArgs, WorkerArgs),
    {ok, {{one_for_one, 10, 10}, [PoolSpec]}}.

get_env(Key, Default) ->
    case application:get_env(erp, Key) of
        {ok, Value} -> Value;
        undefined -> Default
    end.
