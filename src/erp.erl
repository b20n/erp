-module(erp).

-export([start/0, stop/0]).
-export([q/1, q/2, qp/1, qp/2]).

start() ->
    application:start(erp).

stop() ->
    application:stop(erp).

q(Command) ->
    Timeout = application:get_env(erp, timeout, 5000),
    q(Command, Timeout).

q(Command, Timeout) ->
    transact({q, Command, Timeout}, Timeout).

qp(Commands) ->
    Timeout = application:get_env(erp, timeout, 5000),
    qp(Commands, Timeout).

qp(Commands, Timeout) ->
    transact({q, Commands, Timeout}, Timeout).

transact(Msg, Timeout) ->
    Pid = pg2:get_closest_pid(erp),
    gen_server:call(Pid, Msg, Timeout).






