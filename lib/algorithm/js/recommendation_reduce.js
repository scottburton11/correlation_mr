function(key, values) {
	var location_scores = values[0].location_scores;
	var similarities = values[0].similarities;
	var location_score_sums = {};
	var similarity_sums = {};
	var recommendations = {};
	
	for(location in location_scores){
		if (location_score_sums[location] == undefined){
			location_score_sums[location] = 0;
			similarity_sums[location] = 0;
		}
		location_scores[location].forEach(function(score){
			location_score_sums[location] += score;
		});
		similarities[location].forEach(function(score){
			similarity_sums[location] += score;
		});
	}
	
	for (location in location_score_sums){
		recommendations[location] = (location_score_sums[location]/similarity_sums[location]);
	}
	
	return recommendations;
	
};