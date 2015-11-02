# Introduction:

This folder contains all the source code used by the FITMAN Generic Enabler "GeToVa".

The GeToVa Specific Enabler is available at: http://fitman.sti2.at/

# Getting started:

Running the whole application requires to:

1. install docker and docker-compose:

* https://docs.docker.com/installation/
* https://docs.docker.com/compose/install/

2. cd into this folder and run:

> docker-compose build getova

* if you are using boot2docker run:

> docker-compose up

If you are using boot2docker (MacOS) it will start the servers at <boot2dockerip>:3000 <boot2dockerip>:9200/9300

* alternatively run:

> docker-compose -f noboot2docker.yml up 

This starts the GeToVa server at losthost:3000
It will also start an ElasticSearch server at localhost:9200/9300 

# Folder structure:

## getova:
The main application handling the web interface and the REST API
Also contains the clustering component

## getova/webinterface:
the rails application handling the webinterface (frontend and REST API)

## getova/data_extractor: 
scripts and tools to extract resume / CV information via GATE as well as tools to extract company data for several Use-Cases 

## getova/json2ontology:
a gem used by GeToVa to perform the transformations

## scripts:
some helpful scripts for development

## elasticsearch:
configuration used by docker for elastic search

## api:
documentation and usage of the GeToVa api

