require_relative "spec_helper"
require "rdf/ntriples"

graph = RDF::Graph.new << [:hello, RDF::DC.title, "Hello, world!"]
graph.dump(:ntriples)
