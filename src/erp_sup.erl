-module(erp_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).
-export([spawn_worker/0]).

spawn_worker() ->
    supervisor:start_child(?MODULE, []).

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    WorkerCount = application:get_env(erp, workers, 50),
    lists:foreach(fun(_) -> spawn_worker() end, lists:seq(1, WorkerCount)),
    {ok, Pid}.

init([]) ->
    pg2:create(erp),
    Host = application:get_env(erp, host, "127.0.0.1"),
    Port = application:get_env(erp, port, 6379),
    Spec = {
        erp_worker,
        {erp_worker, start_link, [[{host, Host}, {port, Port}]]},
        permanent,
        5000,
        worker,
        [erp_worker]
    },
    {ok, {{simple_one_for_one, 10000, 1}, [Spec]}}.

