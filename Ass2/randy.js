function bertieMove(board){
	var complete = false;
	while(!complete){
		var row = Math.floor(Math.random() * 2);
		var col = Math.floor(Math.random() * 2);

		if(board[row][col] == ' '){
			board[row][col] = 'x';
			complete = true;
		}
	}
	return board;
}
