%%---------------------------------------------------------------------------%%
%% Server for the weather program
%%---------------------------------------------------------------------------%%
-module(weather).
-compile(export_all).
-import(util).

start() ->
    spawn(fun() -> writer() end),
    % return the reader
    spawn(fun() -> read() end).

%rpc(Pid, Request) ->
%    Pid ! {self(), Request},
%    receive
%        {Pid, Response} ->
%        Response
%    end .

read() ->
    dets:open_file(weather, [{file, "/home/jbq/weather.dat"}]),
    dets:open_file(weather_hits, [{file, "/home/jbq/weather_hits.dat"}]),
    dets:insert(weather_hits, {toulouse, 0}),
    respond().

% FIXME close databases when done
respond() ->
    receive
        {Sender, weather, City} ->
            %io:format("Received weather request for ~p~n", [City]),
            W = dets:lookup(weather, City),
            dets:update_counter(weather_hits, City, 1),
            %io:format("~p sending weather response ~p to ~p~n", [self(), W, Sender]),
            Sender ! {self(), W};
        Any ->
            io:format("Received:~p~n",[Any])
    end,

    respond().


writer() ->
    dets:open_file(weather, [{file, "/home/jbq/weather.dat"}]),
    update_weather().

update_weather() -> update_weather(cloudy).

% FIXME close database when done
update_weather(W) ->
    util:sleep(5000),
    UW = case W of
        sunny -> cloudy;
        cloudy -> sunny
    end,
    %io:format("Weather: ~p~n",[UW]),
    dets:insert(weather, {toulouse, UW}),
    update_weather(UW).
