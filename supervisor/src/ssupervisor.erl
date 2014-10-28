-module(ssupervisor).
-compile(export_all).

start(Ref, UserPid) ->
   spawn(?MODULE, init, [Ref, UserPid]).

init(Ref, UserPid) ->
  process_flag(trap_exit, true),
  supervise_new_fragile_child(Ref, UserPid).

loop({Ref, UserPid, ChildPid}) ->
  receive 
     {'EXIT', ChildPid, _ } -> supervise_new_fragile_child(Ref, UserPid)
  end.

supervise_new_fragile_child(Ref, UserPid) ->
  ChildPid = fragile_child:start_link(),
  UserPid ! {Ref, child_started, ChildPid},
  loop({Ref, UserPid, ChildPid}).