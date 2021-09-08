# tictactoe_mips
TicTacToe written entirely in Assembly. Written 6 days after starting to learn the language!

# The Technical Challenges

As programmers working in high-level languages, we take a lot of things for granted. We work on the backs of thousands of programmers before us creating compilers, interpreters, browsers. operating systems, etc, to make our job easier. Stripping yourself of the majority of these tools and advancements leaves you back at square one having to do everything manually. Something as simple as a function call increases in complexity ten-fold.

Writing a game of Tic-Tac-Toe is a simple challenge which suddenly becomes a difficult challenge when you work on the metal, manipulating memory and values directly, rather than having the liberty of their abstractions. On top of this, I wrote it after only one week of beginning to work in the language. 

# The Goal

Using QTSpim to simulate MIPS assembly, my goal was to have a fully playable and working version of TTT in the console. This would involve the following challenges:

- Printing the board state (manually calculating and reading their memory addresses, and forming text to print)
- Read values from the user and validate
- Creating an algorithm to determine if there was a winner on any given turn
- Determining if a draw occured

To do this, we need to artificially create the following constructs to decompose the problem:
- Loops
- Functions (managing the stack)
- If/Else statements

Ultimately, this amounted to 700 lines of beautiful, beautiful code. It was a very fun challenge that I put up for myself - when I began to understand how higher level languages relate to the constructs in Assembly, I was able to expand upon the concepts and come to this project in roughly a day.
