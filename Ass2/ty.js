function bertieMove(board){
	//First will play in the middle if available
	if(board[1][1] == ' '){
		board[1][1] = 'x';
		return board;
	}else if(board != nextToDouble(board)){		//If can't play in middle, plays next to a double to either win, or stop player
		return nextToDouble(board)
	}else{
		//play randomly, since this AI doesn't necessarily play to win
		var complete = false;
		while(!complete){
			var row = Math.floor(Math.random() * 2);
			var col = Math.floor(Math.random() * 2)

			if(board[row][col] == ' '){
				board[row][col] = 'x';
				complete = true;
			}
		}
		return board;
	}
}

function nextToDouble(board){
	//Plays next to anyone about to win
	for(x = 0; x < 3; x++){
		for(y = 0; y < 3; y++){
			//Should check all rows for doubles
			if(board[x][y] == ' '){
				if(board[x][(y+1) % 3] == board[x][(y+2) % 3] && board[x][(y+1) % 3] != ' ')
					board[x][y] = 'x';
					return board;
			}
			//Should check all columns for doubles
			if(board[x][y] == ' '){
				if(board[(x+1) % 3][y] == board[(x+2) % 3][y] && board[(x+1) % 3][y] != ' ')
					board[x][y] = 'x';
					return board;
			}
		}
	}
	//Check diagonals, there will always be an item in the middle before this is called
	if(board[0][0] == ' ' && board[1][1] == board[2][2] && board[1][1] != ' '){
		board[0][0] = 'x'
		return board;
	}
	if(board[0][2] == ' ' && board[1][1] == board[2][0] && board[1][1] != ' '){
		board[0][2] = 'x'
		return board;
	}
	if(board[2][0] == ' ' && board[1][1] == board[0][2] && board[1][1] != ' '){
		board[2][0] = 'x'
		return board;
	}
	if(board[2][2] == ' ' && board[1][1] == board[0][0] && board[1][1] != ' '){
		board[2][2] = 'x'
		return board;
	}

	//Return the final unchanged board if there are no doubles on the board
	return board;
}
