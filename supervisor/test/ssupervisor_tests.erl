-module(ssupervisor_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").


supervisor_starts_child_test() ->
  ssupervisor:start(self()),
  receive
    {child_started, _ } -> ok
  after 500 ->
   ?assert(false)
  end.

supervisor_respawns_child_test() ->
  ssupervisor:start(self()),
  receive
    {child_started, Pid} -> ok
  end,
  Pid !  die,
  receive
    {child_started, _} -> ok
  	?assert(false)
  after 500 ->
  end.
