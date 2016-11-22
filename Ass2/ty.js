function bertieMove(boardString){
	//First will play in the middle if available
	if(boardString.charAt(4) == ' '){
	 	return replaceChar(boardString, 4);
	}else if(boardString != nextToDouble(boardString)){		//If can't play in middle, plays next to a double to either win, or stop player
		return nextToDouble(boardString)
	}else{
		//play randomly, since this AI doesn't necessarily play to win
		var complete = false;
		while(!complete){
			var spot = Math.floor(Math.random() * 9);

			if(boardString.charAt(spot) == ' '){
				var toReturn = boardString.substr(0, spot) + 'X' + boardString.substr(spot+1);
				complete = true;
			}
		}
		return toReturn;
	}
}

function nextToDouble(boardString){
	//Plays next to anyone about to win
	for(x = 0; x < 3; x++){
		for(y = 0; y < 3; y++){
			//Should check all rows for doubles
			if(boardString.charAt(3*x + y) == ' '){
				if(boardString.charAt(3*x + ((y+1) % 3)) == boardString.charAt(3*x + ((y+2) % 3)) && boardString.charAt(3*x + ((y+1) % 3)) != ' ')
					return replaceChar(boardString, (3*x + y));
			}
			//Should check all columns for doubles
			if(boardString.charAt(3*x + y) == ' '){
				if(boardString.charAt((3*((x+1) % 3)) + y) == boardString.charAt((3*((x+2) % 3)) + y) && boardString.charAt((3*((x+1) % 3)) + y) != ' ')
					return replaceChar(boardString, (3*x + y));
			}
		}
	}
	//Check diagonals, there will always be an item in the middle before this is called
	if(boardString.charAt(0) == ' ' && boardString.charAt(4) == boardString.charAt(8) && boardString.charAt(4) != ' '){
		return replaceChar(boardString, 0);
	}
	if(boardString.charAt(2) == ' ' && boardString.charAt(4) == boardString.charAt(6) && boardString.charAt(4) != ' '){
		return replaceChar(boardString, 2);
	}
	if(boardString.charAt(6) == ' ' && boardString.charAt(4) == boardString.charAt(2) && boardString.charAt(4) != ' '){
		return replaceChar(boardString, 6);
	}
	if(boardString.charAt(8) == ' ' && boardString.charAt(4) == boardString.charAt(0) && boardString.charAt(4) != ' '){
		return replaceChar(boardString, 8);
	}

	//Return the final unchanged boardString if there are no doubles on the boardString
	return boardString;
}

function replaceChar(inString, index){
	return inString.substr(0, index) + 'X' + inString.substr(index+1);
}
