-module(board_alt).
-compile(export_all).

start() ->
  spawn(?MODULE, init, [4]).

init(Size) ->
  Cells = create_cells(Size),
  ready({Cells, Cells, create_compressors(Size), Size}).

create_cells(Size) ->
  lists:duplicate(Size, lists:duplicate(Size, nil)).

create_compressors(Size) ->
  [ compressor:start() || _ <- lists:seq(1, Size) ].

ready(S = {Rows, Columns, Compressors, Size}) ->
  receive 
    {Ref, move, right} -> 
      do_compress(Ref, Size, row, Rows, Compressors),
      waiting({Ref, S, Size});
    {Ref, move, down} ->
      do_compress(Ref, Size, column, Columns, Compressors),
      waiting({Ref, S, Size});
    {set_value, X, Y, Value} ->
      ready(update_matrix(row, new_slice(X, Y, Value, Rows), Y, S));
    {Pid, Ref, render} ->
      Pid ! {Ref, Rows},
      ready(S)
  end.

waiting({Ref, S, Pending}) ->
  receive
    {Ref, set_slice, Type, Slice, Index} ->
      NewS = update_matrix(Type, Slice, Index, S),
      case Pending of
        1 -> ready(NewS);
        _ -> waiting({Ref, NewS, Pending - 1})
      end
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

new_slice(C1, C2, Value, Slices) ->
  listsx:setnth(C1, Value, lists:nth(C2, Slices)).

do_compress(Ref, Size, Type, Slices, Compressors) -> 
  lists:foreach(fun({Slice, Compressor, Index}) ->
    compressor:compress_slice(Ref, Compressor, Type, Slice, Index)
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
  Ref = make_ref(), 
  Pid ! {Ref, move, Direction}.

set_cell(Pid, X, Y, Value) ->
  Pid ! { set_value, X, Y, value_for(Value) }.

set_slice(Pid, Ref, Type, Slice, Index) ->
  Pid ! {Ref, set_slice, Type, Slice, Index}.

value_for(nil) -> nil;
value_for(N) -> {val, N}.

