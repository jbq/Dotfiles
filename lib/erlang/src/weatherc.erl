%%---------------------------------------------------------------------------%%
%% Client for the weather program
%%---------------------------------------------------------------------------%%
-module(weatherc).
-compile(export_all).

do(W) ->
    W ! {self(), weather, toulouse},
    util:sleep(1000),
    receive {W, Weather} -> Weather end,
    io:format("Weather=~p~n", [Weather]),
    util:sleep(1000),
    do(W).

start() ->
    W=weather:start(),
    do(W).
