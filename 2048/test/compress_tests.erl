-module(compress_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
 
empty_slice_test() ->
  ?assertEqual([nil,   nil, nil,   nil], compress:compress([nil,   nil, nil,   nil])).

moves_one_position_test() ->
  ?assertEqual([nil,   nil, nil, {val, 2}],compress:compress([nil,   {val, 2}, nil,   nil])).

moves_mutiple_positions_test() ->
  ?assertEqual(
    [nil,   nil, nil, {val, 2}],
    compress:compress([{val, 2}, nil,   nil,   nil])).

does_simple_merge_test() ->
  ?assertEqual(
    [nil,   nil, nil, {val, 4}], 
    compress:compress([nil,   nil, {val, 2}, {val, 2}])).

does_complex_merge_test() ->
  ?assertEqual(
    [nil,   nil, {val, 4}, {val, 4}],
    compress:compress([{val, 2}, {val, 2}, {val, 2}, {val, 2}])).

does_not_merge_when_impossible_test() ->
  ?assertEqual(
    [nil, nil, {val, 4}, {val, 2}],
    compress:compress([nil, nil, {val, 4}, {val, 2}])).

merges_in_single_step_test() ->
  ?assertEqual(
    [nil, nil, {val, 4}, {val, 4}], 
    compress:compress([{val, 2}, {val, 2}, {val, 4}, nil])).