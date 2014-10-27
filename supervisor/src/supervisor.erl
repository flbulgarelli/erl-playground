-module(supervisor).
-compile(export_all).


start() ->
   spawn(?MODULE, init, []).

init() ->
  process_flag(trap_exit, true),
  supervise_new_fragile_child().

loop(ChildPid) ->
  receive 
     {'DOWN', ChildPid} -> supervise_new_fragile_child()
 end.

supervise_new_fragile_child() ->
  loop(fragile_child:start_link()).