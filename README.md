This is a project from the [Odin Project](http://www.theodinproject.com/courses/ruby-programming/lessons/ruby-final-project?ref=lnav)

Chess
----

This is a chess program that is played on the command line. To start the program execute the game.rb file from the lib directory.

[](/screenshots/Menu_screenshot.png)

The game can be played by two players or you can play against a simple AI who makes a random legal move.

Saved games can be loaded from the starting menu.

[](/screenshots/start_screenshot.png)

Gameplay
----

To make a move enter the chess notation of the starting square and the end square. For example, 'g1 f3' or 'G1 F3'. You can also enter 'save' to save your current game.

[](/screenshots/move_screenshot.png)

Only legal chess moves are allowed. If a player is in check, they must make a move that will not leave them in check. The game ends when a player is in checkmate or when a stalemate occurs. A stalemate happens when a player is not in check but has no legal moves.

Chess special moves are allowed, such as castling, pawn double moves, pawn promotion, and en passant.

Draw
----

Draws other than stalemate have not been implemented. These include:

Draw by agreement

Threefold repetition

Fifty move rule

Insufficient material