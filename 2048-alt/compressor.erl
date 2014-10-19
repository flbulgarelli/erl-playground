-module(compressor).
-compile(export_all).

start() ->
  spawn(?MODULE, loop, []).

loop() ->
  receive
    {Pid, compress, forward, Type, Cells, Index} ->
      NewCels = compress(Cells),
      board:set_slice(Pid, Type, NewCels, Index)
  end,
  loop().

compress_slice(Pid, Type, Slice, Index) ->
  Pid ! {self(), compress, forward, Type, Slice, Index}.

compress([X])               -> [X];
compress([nil|Xs])          -> [nil|compress(Xs)];
compress([{val, X},nil|Xs]) -> [nil|compress([{val, X}|Xs])];
compress([{val, X}|Xs])     -> tryCompress({val, X}, compress(Xs)).

tryCompress(X, Xs = [nil|_]) -> compress([X|Xs]);
tryCompress({val, X}, [{val, Y}|Xs]) when X =:= Y -> [nil,{val, 2 * X}|Xs];
tryCompress(X, Xs) -> [X|Xs].
