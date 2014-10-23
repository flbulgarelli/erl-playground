-module(compressor).
-compile(export_all).

start() ->
  spawn(?MODULE, loop, []).

loop() ->
  receive
    {Pid, Ref, compress, forward, Type, Cells, Index} ->
      NewCels = compress:compress(Cells),
      board_alt:set_slice(Pid, Ref, Type, NewCels, Index)
  end,
  loop().

compress_slice(Ref, Pid, Type, Slice, Index) ->
  Pid ! {self(), Ref, compress, forward, Type, Slice, Index}.

