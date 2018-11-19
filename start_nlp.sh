#!/bin/bash
echo $CLASSPATH
java -cp "/home/stanford_nlp/stanford-corenlp-full-2017-06-09/*"  -mx4g edu.stanford.nlp.pipeline.StanfordCoreNLPServer &
# Wait until server starts
while ! nc -z localhost 9000; do
    sleep 0.1 # wait for 1/10 of the second before check again
done