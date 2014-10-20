-module(listsx).
-compile(export_all).

setnth(Index, Value, Xs) -> setnth1(Index, Value, Xs, 1).

setnth1(Index, Value, [_|Xs], N) when N =:= Index -> [Value|Xs];
setnth1(Index, Value, [X|Xs], N) -> [X|setnth1(Index, Value, Xs, N + 1)].
