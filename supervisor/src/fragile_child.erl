-module(fragile_child).
-compile(export_all).

start_link() ->
  spawn_link(?MODULE, loop, []).

 loop() ->
   receive
     _ ->  io:format("dying for normal reasons")
   end.