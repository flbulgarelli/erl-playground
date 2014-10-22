-module(slice).
-compile(export_all).

start(Size, Position) ->
  spawn(?MODULE, init, [Size, Position]).

init(Size, Position) ->
  starting({lists:duplicate(Size, nil), Position}).

starting({Cells, Position}) ->
  receive 
    {set_ortogonal, NewOrtogonalSlices} ->
      ready({Cells, Position, NewOrtogonalSlices})
  end.

ready(S = {Cells, Position, OrtogonalSlices}) ->
  receive
    {Ref, compress, forward} ->
      NewCells = compress:compress(Cells),
      [sync_cell(Pid, Ref, Position, Cell) ||
      	 {Pid, Cell} <- lists:zip(OrtogonalSlices, NewCells)],
      ready({NewCells, Position, OrtogonalSlices});
    {set_cell, Index, Value} ->
      ready(do_update_cell(Index, Value, S));
    {Pid, Ref, get_value} ->
      Pid ! { Ref, Cells},
      ready(S);
    {Ref, sync} ->
      waiting({Ref, length(Cells), S}) %% TODO syncronize by position, not count
  end.

waiting({Ref, Pending, S}) ->
  receive
    {Ref, sync_cell, Index, Value} ->
      case Pending =:= 1 of
        true -> ready(do_update_cell(Index, Value, S));
        false -> waiting({Ref, Pending - 1, do_update_cell(Index, Value, S)})
      end
  end. %%TODO death on timeout

do_update_cell(Index, Value, {Cells, Position, OrtogonalSlices}) ->
  {listsx:setnth(Index, Value, Cells), Position, OrtogonalSlices}.

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

sync_cell(Pid, Ref, Index, Value) ->
  Pid ! {Ref, sync_cell, Index, Value}.

set_cell(Pid, Index, Value) ->
  Pid ! {set_cell, Index, Value}.

set_ortogonal_slices(Rows, Columns) ->
  [Pid ! {set_ortogonal, Columns} || Pid <- Rows],
  [Pid ! {set_ortogonal, Rows} || Pid <- Columns].

sync(Ref, Pid) ->
  Pid ! {Ref, sync}.

compress_forward(Ref, Pid) ->
  Pid ! {Ref, compress, forward}.

value_for(nil) -> nil;
value_for(N) -> {val, N}.

