function() {
	var location_scores = {};
	var similarities = {};
	var me = this;
	 db.people.find({name: {$in: this.follows}}).forEach(function(person){
		for(location in person.reviews) {
			if(location_scores[location] == undefined){
        location_scores[location] = [];
			}
			if(similarities[location] == undefined){
			  similarities[location] = [];
			}
			if (me.scores[person.name] && !(location in me.reviews)){
				var adj_sim = (1+me.scores[person.name])/2;
				location_scores[location].push((person.reviews[location] * adj_sim));
				similarities[location].push(adj_sim);								
			}
		}
 	 });
  emit(me._id, {location_scores: location_scores, similarities: similarities});
};