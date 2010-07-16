module MapReduce
  extend self

  def run
    results = Database.people.map_reduce(map, reduce)
    return results
  end
  
  def map
    raise RuntimeError, "called MR module method\n\nOverwrite this with a #map method in the receiving class containing a string describing a Javascript function:\n\ndef map\n  \"function(){};\"\nend\n\n"
  end
  
  def reduce
    raise RuntimeError, "called MR module method\n\nOverwrite this with a #reduce method in the receiving class containing a string describing a Javascript function:\n\ndef reduce\n  \"function(key, values){};\"\nend\n\n"
  end
end