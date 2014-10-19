Check what happens: 
```erlang
Pid = echo:start().

echo:say(Pid, foo).
echo:say(Pid, foo).

flush().

[ Pid ! {not_a_say, N } || N <- lists:seq(1, 1000) ].

%% Check the mailbox and process size
erlang:process_info(Pid).

```
