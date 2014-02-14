-module(erp_worker).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, terminate/2, code_change/3]).
-export([handle_call/3, handle_cast/2, handle_info/2]).

-record(st, {
    conn,
    timeout
}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    Host = proplists:get_value(host, Args),
    Port = proplists:get_value(port, Args),
    {ok, C} = eredis:start_link(Host, Port),
    pg2:join(erp, self()),
    {ok, #st{conn=C}}.

handle_call({q, Command, Timeout}, _From, #st{conn=C}=State) ->
    {reply, eredis:q(C, Command, Timeout), State};
handle_call({qp, Commands, Timeout}, _From, #st{conn=C}=State) ->
    {reply, eredis:qp(C, Commands, Timeout), State};
handle_call(Msg, _From, State) ->
    {stop, {unknown_call, Msg}, error, State}.

handle_cast(Msg, State) ->
    {stop, {unknown_cast, Msg}, State}.

handle_info(Msg, State) ->
    {stop, {unknown_info, Msg}, State}.

terminate(_Reason, #st{conn=C}) ->
    eredis:stop(C),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
