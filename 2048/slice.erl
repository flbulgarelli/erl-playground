-module(slice).
-compile(export_all).

start(Size, Position) ->
  spawn(?MODULE, init, [Size, Position]).

init(Size, Position) ->
  loop({lists:duplicate(Size, nil), Position, []}).

loop(S = {Cells, Position, OrtogonalSlices}) ->
  receive
    {set_ortogonal, NewOrtogonalSlices} ->
      loop({Cells, Position, NewOrtogonalSlices});
    {compress, forward} ->
      NewCels = compress(Cells),
      [set_cell(Pid, Position, Cell) ||
      	 {Pid, Cell} <- lists:zip(OrtogonalSlices, Cells)],
      loop({NewCels, Position, OrtogonalSlices});
    {Pid, Ref, get_value} ->
      Pid ! { Ref, Cells},
      loop(S);
    {set_cell, Index, Value} ->
      loop({setnth(Index, Value, Cells), Position, OrtogonalSlices})
  end.

get_value(Pid) ->
  Ref = monitor(process, Pid),
  Pid ! {self(), Ref, get_value},
  receive 
    {Ref, Cells} ->
      demonitor(Ref),
      Cells;
    {'DOWN', Ref, _, _, _} ->
      nok
  after 1000 ->
    demonitor(Ref),
    timeout
  end.

set_cell(Pid, Index, Value) ->
  Pid ! {set_cell, Index, Value}.

set_ortogonal_slices(Rows, Columns) ->
  [Pid ! {set_ortogonal, Columns} || Pid <- Rows],
  [Pid ! {set_ortogonal, Rows} || Pid <- Columns].
  
compress_forward(Pid) ->
  Pid ! {compress, forward}.

compress([X])               -> [X];
compress([nil|Xs])          -> [nil|compress(Xs)];
compress([{val, X},nil|Xs]) -> [nil|compress([{val, X}|Xs])];
compress([{val, X}|Xs])     -> tryCompress({val, X}, compress(Xs)).

tryCompress(X, Xs = [nil|_]) -> compress([X|Xs]);
tryCompress({val, X}, [{val, Y}|Xs]) when X =:= Y -> [nil,{val, 2 * X}|Xs];
tryCompress(X, Xs) -> [X|Xs].

setnth(Index, Value, Xs) -> setnth1(Index, Value, Xs, 1).

setnth1(Index, Value, [_|Xs], N) when N =:= Index -> [Value|Xs];
setnth1(Index, Value, [X|Xs], N) -> [X|setnth1(Index, Value, Xs, N + 1)].

value_for(nil) -> nil;
value_for(N) -> {val, N}.

