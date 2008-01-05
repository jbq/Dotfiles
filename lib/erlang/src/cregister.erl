-module(cregister).
-compile(export_all).
-import(util).

test() ->
	launch(abcd, fun() -> coucou() end),
	launch(abcd, fun() -> coucou() end)
.

launch(Atom, Fun) ->
	case start(Atom, Fun) of
		true -> io:format("SUCCESS~n");
		false -> io:format("FAILURE~n")
	end
.

start(Atom, Fun) ->
	io:format("Registering as ~p~n", [Atom]),
	Launcher = spawn(fun() ->
			receive
				ok -> Fun();
				_ -> void
			end
		end),
	try
		register(Atom, Launcher),
		Launcher ! ok,
		true
	catch error:_ ->
		Launcher ! stop,
		false
	end
.

coucou() ->
	util:sleep(1000),
	io:format("Hello from ~p~n", [self()]),
	coucou()
.
