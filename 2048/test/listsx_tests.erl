-module(listsx_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

setnth_test() ->
   ?assertEqual([a, b, c], listsx:setnth(2, b, [a, d, c])).
