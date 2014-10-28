-module(ssupervisor).
-compile(export_all).

start(UserPid) ->
   spawn(?MODULE, init, [UserPid]).

init(UserPid) ->
  process_flag(trap_exit, true),
  supervise_new_fragile_child(UserPid).

loop({UserPid, ChildPid}) ->
  receive 
     {'EXIT', ChildPid, _ } -> supervise_new_fragile_child(UserPid)
  end.

supervise_new_fragile_child(UserPid) ->
  ChildPid = fragile_child:start_link(),
  UserPid ! {child_started, ChildPid},
  loop({UserPid, ChildPid}).