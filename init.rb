require 'rubygems'
require 'mongo'
require 'json'
require 'pp'
require 'lib/mapreduce'
require 'lib/standard_additions/text_formatting'

Dir[File.expand_path(File.dirname(__FILE__) + "/lib/algorithm/**/*.rb")].each {|file| require file}

include TextFormatting
include Algorithm

title "Starting the correlation algorithm:"
title "This run uses Euclidian Distance:"
description "Euclidian Distance is a simple score calculated by squaring the difference between two points, then inverting it. It generates a score between 0 and 1, and does not normalize the differences."
Euclidian.run

title "This run uses the Pearson Correlation:"
description "The Pearson Correlation scores between -1 and 1, with 1 indicating strong similarity and -1 indicating strong dissimilarity. An interesting feature of the Pearson Correlation is its inherint normalization - if two datasets generally agree, but vary in the width of their scoring range, it will still indicate a that they are similar."
Pearson.run