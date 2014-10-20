-module(compress).
-compile(export_all).

compress([X])               -> [X];
compress([nil|Xs])          -> [nil|compress(Xs)];
compress([{val, X},nil|Xs]) -> [nil|compress([{val, X}|Xs])];
compress([{val, X}|Xs])     -> tryCompress({val, X}, compress(Xs)).

tryCompress(X, Xs = [nil|_]) -> compress([X|Xs]);
tryCompress({val, X}, [{val, Y}|Xs]) when X =:= Y -> [nil,{val, 2 * X}|Xs];
tryCompress(X, Xs) -> [X|Xs].
