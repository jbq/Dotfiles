-module(shop1).
-export([total/1]).
%-import(lists, map/2).
%total([{What, N}|T]) -> shop:cost(What) * N + total(T);
total(L) -> lists:sum(lists:map(fun({What, N}) -> shop:cost(What) * N end, L)).
