-module(erp).

-export([start/0, stop/0]).
-export([q/1, q/2, qp/1, qp/2]).

-define(TIMEOUT, 5000).

start() ->
    application:start(erp).

stop() ->
    application:stop(erp).

q(Command) ->
    q(Command, ?TIMEOUT).

q(Command, Timeout) ->
    transact({q, Command, Timeout}).

qp(Commands) ->
    qp(Commands, ?TIMEOUT).

qp(Commands, Timeout) ->
    transact({q, Commands, Timeout}).

transact(Msg) ->
    poolboy:transaction(redis, fun(W) -> gen_server:call(W, Msg) end).
