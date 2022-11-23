# Solving Every Sudoku Puzzle


Peter Norvig presents a nice and simple way to solve every Sudoku puzzle in
http://norvig.com/sudoku.html, and mention some ports of his effort. He
picked python to implement his solver, and the Ruby ports are dead links.

Let's begin by copying the introduction as-is:

## Sudoku Notation and Preliminary Notions

First we have to agree on some notation. A Sudoku puzzle is a grid of 81
squares; the majority of enthusiasts label the columns 1-9, the rows A-I,
and call a collection of nine squares (column, row, or box) a unit and the
squares that share a unit the peers. A puzzle leaves some squares blank and
fills others with digits, and the whole idea is:

  A puzzle is solved if the squares in each unit are filled with a
  permutation of the digits 1 to 9.

That is, no digit can appear twice in a unit, and every digit must appear once. 
This implies that each square must have a different value from any of its peers.

    A1 A2 A3| A4 A5 A6| A7 A8 A9    4 . . |. . . |8 . 5     4 1 7 |3 6 9 |8 2 5 
    B1 B2 B3| B4 B5 B6| B7 B8 B9    . 3 . |. . . |. . .     6 3 2 |1 5 8 |9 4 7
    C1 C2 C3| C4 C5 C6| C7 C8 C9    . . . |7 . . |. . .     9 5 8 |7 2 4 |3 1 6 
    ---------+---------+---------    ------+------+------    ------+------+------
    D1 D2 D3| D4 D5 D6| D7 D8 D9    . 2 . |. . . |. 6 .     8 2 5 |4 3 7 |1 6 9 
    E1 E2 E3| E4 E5 E6| E7 E8 E9    . . . |. 8 . |4 . .     7 9 1 |5 8 6 |4 3 2 
    F1 F2 F3| F4 F5 F6| F7 F8 F9    . . . |. 1 . |. . .     3 4 6 |9 1 2 |7 5 8 
    ---------+---------+---------    ------+------+------    ------+------+------
    G1 G2 G3| G4 G5 G6| G7 G8 G9    . . . |6 . 3 |. 7 .     2 8 9 |6 4 3 |5 7 1 
    H1 H2 H3| H4 H5 H6| H7 H8 H9    5 . . |2 . . |. . .     5 7 3 |2 9 1 |6 8 4 
    I1 I2 I3| I4 I5 I6| I7 I8 I9    1 . 4 |. . . |. . .     1 6 4 |8 7 5 |2 9 3 

 Every square has exactly 3 units and 20 peers. For example, here are the units and peers for the square C2:

    A2   |         |                    |         |            A1 A2 A3|         |         
    B2   |         |                    |         |            B1 B2 B3|         |         
    C2   |         |            C1 C2 C3| C4 C5 C6| C7 C8 C9   C1 C2 C3|         |         
    ---------+---------+---------  ---------+---------+---------  ---------+---------+---------
    D2   |         |                    |         |                    |         |         
    E2   |         |                    |         |                    |         |         
    F2   |         |                    |         |                    |         |         
    ---------+---------+---------  ---------+---------+---------  ---------+---------+---------
    G2   |         |                    |         |                    |         |         
    H2   |         |                    |         |                    |         |         
    I2   |         |                    |         |                    |         |         