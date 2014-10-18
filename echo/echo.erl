-module(echo).
-compile(export_all).

loop() -> 
   receive
     {Pid, Ref, say, Message} -> 
          Pid ! {Ref, Message},
          loop()
   end.

start() ->
   spawn(?MODULE, loop, []).

say(Pid, Message) ->
   Ref = make_ref(),
   Pid ! {self(), Ref, say, Message},
   Ref.
   

