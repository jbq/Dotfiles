-module(util).
-export([sleep/1]).

sleep(Millis) ->
	receive
		void -> void
	after Millis ->
		void
	end
.
