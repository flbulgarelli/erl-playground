-module(board_alt).
-compile(export_all).

start() ->
  spawn(?MODULE, init, [4]).

init(Size) ->
  Cells = create_cells(Size),
  loop({Cells, Cells, create_compressors(Size), Size}).

create_cells(Size) ->
  lists:duplicate(Size, lists:duplicate(Size, nil)).

create_compressors(Size) ->
  [ compressor:start() || _ <- lists:seq(1, Size) ].

loop(S = {Rows, Columns, Compressors, Size}) ->
  receive 
    {move, right} -> 
      do_compress(Size, row, Rows, Compressors),
      loop(S);
    {move, down} ->
      do_compress(Size, column, Columns, Compressors),
      loop(S);
    {set_slice, Type, Slice, Index} ->
      loop(update_matrix(Type, Slice, Index, S));
    {set_value, X, Y, Value} ->
      S1 = update_matrix(row, new_slice(X, Y, Value, Rows), Y, S),
      S2 = update_matrix(column, new_slice(Y, X, Value, Columns), X, S1),
      loop(S2);
    {Pid, Ref, render} ->
      Pid ! {Ref, Rows},
      loop(S)
  end.

update_matrix(Type, Slice, Index, {Rows, Columns, Compressors, Size}) ->
  case Type of 
    row ->
      {listsx:setnth(Index, Slice, Rows), set_orthogonal(Index, Slice, Columns), Compressors, Size};
    column ->
      {set_orthogonal(Index, Slice, Rows), listsx:setnth(Index, Slice, Columns), Compressors, Size}
  end.

set_orthogonal(Index, Slice, OrthogonalSlices) ->
   [ listsx:setnth(Index, Cell, OrthogonalSlice) || 
      {Cell, OrthogonalSlice} <- lists:zip(Slice, OrthogonalSlices) ].

new_slice(C1, C2, Value, Slice) ->
  listsx:setnth(C2, Value, lists:nth(C1, Slice)).

do_compress(Size, Type, Slices, Compressors) -> 
  lists:foreach(fun({Slice, Compressor, Index}) ->
    compressor:compress_slice(Compressor, Type, Slice, Index)
  end, lists:zip3(Slices, Compressors, lists:seq(1, Size))).

render(Pid) ->
  Ref = make_ref(),
  Pid ! { self(), Ref, render},
  receive
    {Ref, Cells} -> Cells
  after 5000 ->
    timeout
  end.

move(Pid, Direction) ->
   Pid ! {move, Direction}.

set_value(Pid, X, Y, Value) ->
  Pid ! { set_value, X, Y, value_for(Value) }.

set_slice(Pid, Type, Slice, Index) ->
  Pid ! {set_slice, Type, Slice, Index}.

value_for(nil) -> nil;
value_for(N) -> {val, N}.

