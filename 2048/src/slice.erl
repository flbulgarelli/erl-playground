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
      NewCells = compress:compress(Cells),
      [set_cell(Pid, Position, Cell) ||
      	 {Pid, Cell} <- lists:zip(OrtogonalSlices, NewCells)],
      loop({NewCells, Position, OrtogonalSlices});
    {Pid, Ref, get_value} ->
      Pid ! { Ref, Cells},
      loop(S);
    {set_cell, Index, Value} ->
      loop({listsx:setnth(Index, Value, Cells), Position, OrtogonalSlices})
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

value_for(nil) -> nil;
value_for(N) -> {val, N}.

