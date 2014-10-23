-module(board_alt_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

start_sample_board() ->
   Board = board_alt:start(),
   board_alt:set_cell(Board, 2, 3, 2),
   board_alt:set_cell(Board, 4, 1, 4),
   Board.
  
can_set_cell_in_diagonal_test() ->
   Board = board_alt:start(),
   board_alt:set_cell(Board, 1, 1, 2),
   Matrix = board_alt:render(Board),
   ?assertEqual([
   	[{val, 2}, nil,nil,nil],
   	[nil,      nil,nil,nil],
   	[nil,      nil,nil,nil],
   	[nil,      nil,nil,nil]
   ], Matrix).

can_set_cell_outside_diagonal_test() ->
   Board = start_sample_board(),
   Matrix = board_alt:render(Board),
   ?assertEqual([
   	[nil, nil,     nil,{val, 4}],
   	[nil, nil,     nil,     nil],
   	[nil, {val, 2},nil,     nil],
   	[nil, nil,     nil,     nil]
   ], Matrix).


can_move_right_test() ->
   Board = start_sample_board(),
   board_alt:move(Board, right),
   Matrix = board_alt:render(Board),
   ?assertEqual([
   	[nil, nil, nil, {val, 4}],
   	[nil, nil, nil, nil     ],
   	[nil, nil, nil, {val, 2}],
   	[nil, nil, nil, nil     ]
   ], Matrix).

can_move_down_test() ->
   Board = start_sample_board(),
   board_alt:move(Board, down),
   Matrix = board_alt:render(Board),
   ?assertEqual([
   	[nil, nil,      nil, nil    ],
   	[nil, nil,      nil, nil    ],
   	[nil, nil,      nil, nil    ],
   	[nil, {val, 2}, nil, {val, 4}]
   ], Matrix).

can_move_right_and_down_test() ->
   Board = start_sample_board(),
   board_alt:move(Board, right),
   board_alt:move(Board, down),
   Matrix = board_alt:render(Board),
   ?assertEqual([
   	[nil, nil, nil, nil     ],
   	[nil, nil, nil, nil     ],
   	[nil, nil, nil, {val, 4}],
   	[nil, nil, nil, {val, 2}]
   ], Matrix).
