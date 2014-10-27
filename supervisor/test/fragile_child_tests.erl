-module(fragile_child_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

dies_on_any_message_test() ->
  Pid = fragile_child:start_link(),
  Ref = monitor(process, Pid),
  Pid ! foo,
  receive 
    {'DOWN', Ref, _, _, _} ->
       ok
  after 500 ->
    ?assert(false)
  end.