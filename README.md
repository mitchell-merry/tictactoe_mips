# tictactoe_mips
TicTacToe written entirely in Assembly. Written 6 days after starting to learn the language!

# The Technical Challenges

It is very difficult to accurately convey the complexity of this project, especially given the timeframe I worked in and the challenges of using a language like Assembly. I recommend opening `tictactoe.s` and scrolling.

As programmers working in high-level languages, we take a lot of things for granted. We work on the backs of thousands of programmers before us creating compilers, interpreters, browsers. operating systems, etc, to make our job easier. Stripping yourself of the majority of these tools and advancements leaves you back at square one having to do everything manually. Something as simple as a function call increases in complexity ten-fold.

Writing a game of Tic-Tac-Toe is a simple challenge which suddenly becomes a difficult challenge when you work on the metal, manipulating memory and values directly, rather than having the liberty of their abstractions. On top of this, I wrote it after only one week of beginning to work in the language. 

It is absolutely CRITICAL in this language to document everything you do - what every register is used for, why we add one to this register, what this function does, etc as debugging is very difficult with our limited tools. Debugging amounted to watching not only for console output but also looking at the actual memory directly and reverse-engineering the values we get.

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

# If I had more time
- I would have tried to make the win checking algorith more general, in that instead of having different functions for row and column, I would have instead passed in a direction as a an argument and checked along that direction. I realised this technique after I had written this code while I was trying to do something similar for checking the diagonals
- Not written it in assembly! ;)
