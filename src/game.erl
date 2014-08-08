-module(game).
-behaviour(gen_server).

%% API.
-export([start_link/0, start/0, up/0,down/0,left/0,right/0]).

-export([drop_zero/1, left/1, right/1]).
%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).


%% API.

start() ->
    application:start(game),
    ok.

up() ->
    gen_server:call(?MODULE, up).

down() ->
    gen_server:call(?MODULE, down).

left() ->
    gen_server:call(?MODULE, left).

right() ->
    gen_server:call(?MODULE, right).
%%==========================

-spec start_link() -> {ok, pid()}.
start_link() ->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

%% gen_server.

init([]) ->
    State = init_state(),
io:format("state:~n~p~n", [State]),
	{ok, State}.


handle_call(up, _From, State) ->
    S1 = up(State),
    NS = case S1 =:= State of
        true  -> S1;
        false -> rand_grid(S1)
    end,
    case is_game_over(NS) of
        true -> {reply, gameover, init_state()};
        false ->{reply, NS, NS}
    end;

handle_call(down, _From, State) ->
    S1 = down(State),
    NS = case S1 =:= State of
        true  -> S1;
        false -> rand_grid(S1)
    end,
    case is_game_over(NS) of
        true -> {reply, gameover, init_state()};
        false ->{reply, NS, NS}
    end;

handle_call(left, _From, State) ->
    S1 = left(State),
    NS = case S1 =:= State of
        true  -> S1;
        false -> rand_grid(S1)
    end,
    case is_game_over(NS) of
        true -> {reply, gameover, init_state()};
        false ->{reply, NS, NS}
    end;

handle_call(right, _From, State) ->
    S1 = right(State),
    NS = case S1 =:= State of
        true  -> S1;
        false -> rand_grid(S1)
    end,
    case is_game_over(NS) of
        true -> {reply, gameover, init_state()};
        false ->{reply, NS, NS}
    end;


handle_call(_Request, _From, State) ->
	{reply, ignored, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


%================================

up([A, B, C, D]) ->
    L = [1,2,3,4],
    S1 = [ {lists:nth(X, t2l(A)), lists:nth(X, t2l(B)), lists:nth(X, t2l(C)), lists:nth(X, t2l(D))} || X <- L],
    [A1, B1, C1, D1] = left(S1),
    S2 = [ {lists:nth(X, t2l(A1)), lists:nth(X, t2l(B1)), lists:nth(X, t2l(C1)), lists:nth(X, t2l(D1))} || X <- L],
    S2.

down([A, B, C, D]) ->
    L = [1,2,3,4],
    S1 = [ {lists:nth(X, t2l(A)), lists:nth(X, t2l(B)), lists:nth(X, t2l(C)), lists:nth(X, t2l(D))} || X <- L],
    [A1, B1, C1, D1] = right(S1),
    S2 = [ {lists:nth(X, t2l(A1)), lists:nth(X, t2l(B1)), lists:nth(X, t2l(C1)), lists:nth(X, t2l(D1))} || X <- L],
    S2.

left([A, B, C, D]) ->
    A1 = add(drop_zero(t2l(A))),
    B1 = add(drop_zero(t2l(B))),
    C1 = add(drop_zero(t2l(C))),
    D1 = add(drop_zero(t2l(D))),
    [l2t(A1), l2t(B1), l2t(C1), l2t(D1)].

right([A, B, C, D]) ->
    A1 = lists:reverse(add(drop_zero(lists:reverse(t2l(A))))),
    B1 = lists:reverse(add(drop_zero(lists:reverse(t2l(B))))),
    C1 = lists:reverse(add(drop_zero(lists:reverse(t2l(C))))),
    D1 = lists:reverse(add(drop_zero(lists:reverse(t2l(D))))),
    [l2t(A1), l2t(B1), l2t(C1), l2t(D1)].

t2l(T) ->
    tuple_to_list(T).
l2t(L) ->
    list_to_tuple(L).


rand_value() ->
    {A1,A2,A3} = now(),
    random:seed(A1, A2, A3),
    R = random:uniform(),
    rand_value(R).

rand_value(R) when R > 0.8 ->
    4;
rand_value(_) ->
    2.

rand_grid(State) ->
    V = rand_value(),
    L = state_to_list(State),
    RandPos = get_random_zero_pos(L),
    L1 = rand_grid(1, RandPos, V, null, [], L),
    list_to_state(L1).


rand_grid(Count, RandPos, V, null, L, [_H|T]) when Count=:=RandPos ->
    rand_grid(Count+1, RandPos, V, ok, [V|L], T);
    
rand_grid(Count, RandPos, V, null, L, [H|T]) ->
    rand_grid(Count+1, RandPos, V, null, [H|L], T);

rand_grid(Count, RandPos, V, ok, L, [H|T]) ->
    rand_grid(Count+1, RandPos, V, ok, [H|L], T);

rand_grid(_Count, _RandPos, _V, ok, L, []) ->
    L1 = lists:reverse(L),
    L1.
    
state_to_list(S) ->
    L = [ tuple_to_list(X) || X <- S],
    lists:flatten(L).

list_to_state(L) ->
    list_to_state([], L).

list_to_state(L, [A, B, C, D|T]) ->
    list_to_state([{A,B,C,D}|L], T);

list_to_state(L, []) ->
    L1 = lists:reverse(L),
    %lists:map(fun(X) -> io:format("~n~p", [X]) end, L1),
    %io:format("~n"),
    L1.
    %list_to_tuple(L).
    


drop_zero(L) ->
    drop_zero([], L).

drop_zero(L, [H|T]) when H=/=0 ->
   drop_zero([H|L], T); 

drop_zero(L, [_H|T]) ->
   drop_zero(L, T); 

drop_zero(L, []) ->
    lists:reverse(L).
    


add([]) -> [0, 0, 0, 0];

add([A]) -> [A, 0, 0, 0];

add([A, B]) when A=:=B -> [A+B, 0, 0, 0];
add([A, B]) -> [A, B, 0, 0];

add([A, B, C]) when (A=:=B) and (B=:=C) -> [A+B, C, 0, 0];
add([A, B, C]) when A=:=B -> [A+B, C, 0, 0];
add([A, B, C]) when B=:=C -> [A, B+C, 0, 0];
add([A, B, C]) -> [A, B, C, 0];

add([A, B, C, D]) when (A=:=B) and (B=:=C) and (C=:=D) -> [A+B, C+D, 0, 0];
add([A, B, C, D]) when (A=:=B) and (C=:=D) -> [A+B, C+D, 0, 0];
add([A, B, C, D]) when A=:=B -> [A+B, C, D, 0];
add([A, B, C, D]) when B=:=C -> [A, B+C, D, 0];
add([A, B, C, D]) when C=:=D -> [A, B, C+D, 0];
add([A, B, C, D]) -> [A, B, C, D].



get_random_zero_pos(L) ->
    ZeroPosition = [ X || X<-lists:seq(1,16), lists:nth(X,L)==0 ],
    Num = random:uniform(length(ZeroPosition)),
    lists:nth(Num, ZeroPosition).
    

init_state() ->
    State = [{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}],
    State1 = rand_grid(State),
    rand_grid(State1).

is_game_over(State) ->
    (up(State) =:= down(State)) and (left(State) =:= right(State)) and (up(State) =:= left(State)).
    


