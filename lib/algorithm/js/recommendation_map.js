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
			location_scores[location].push((person.reviews[location] * me.scores[person.name]));
			similarities[location].push(me.scores[person.name]);
		}
 	 });
  emit(me._id, {location_scores: location_scores, similarities: similarities});
};