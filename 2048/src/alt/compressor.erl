-module(compressor).
-compile(export_all).

start() ->
  spawn(?MODULE, loop, []).

loop() ->
  receive
    {Pid, compress, forward, Type, Cells, Index} ->
      NewCels = compress:compress(Cells),
      board:set_slice(Pid, Type, NewCels, Index)
  end,
  loop().

compress_slice(Pid, Type, Slice, Index) ->
  Pid ! {self(), compress, forward, Type, Slice, Index}.

