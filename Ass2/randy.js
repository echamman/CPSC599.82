function bertieMove(boardString){
	var complete = false;
	while(!complete){
		var spot = Math.floor(Math.random() * 9);

		if(boardString.charAt(spot) == ' '){
			var toReturn = boardString.substr(0, spot) + 'X' + boardString.substr(spot+1);
			complete = true;
		}
	}
	return boardString;
}
