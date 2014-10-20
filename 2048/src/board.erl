-module(board).
-compile(export_all).

start() ->
  spawn(?MODULE, init, [4]).

init(Size) ->
  Rows = create_slices(Size),
  Columns = create_slices(Size),
  slice:set_ortogonal_slices(Rows, Columns), 
  loop({Rows, Columns}).

create_slices(Size) ->
  [ slice:start(Size, Index) || Index <- lists:seq(1, Size) ].

loop(S = {Rows, Columns}) ->
  receive 
    {move, right} -> 
      lists:foreach(fun slice:compress_forward/1, Rows);
    {move, down} ->
      lists:foreach(fun slice:compress_forward/1, Columns);
    {set_cell, XIndex, YIndex, Value} ->
      slice:set_cell(lists:nth(XIndex, Rows), YIndex, Value), 
      slice:set_cell(lists:nth(YIndex, Columns), XIndex, Value);
    {Pid, Ref, render} ->
      Pid ! {Ref, lists:map(fun slice:get_value/1, Rows)}
  end,
  loop(S).

set_cell(Pid, XIndex, YIndex, Value) ->
  Pid ! { set_cell, XIndex, YIndex, slice:value_for(Value) }.

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

