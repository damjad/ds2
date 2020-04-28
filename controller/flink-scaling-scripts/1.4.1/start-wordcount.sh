#!/bin/bash

### ### ###  		   ### ### ###

### ### ### INITIALIZATION ### ### ###

### ### ###  		   ### ### ###

### paths configuration ###
PATH=/home/danish/.jenv/shims:$PATH
FLINK_BUILD_PATH="/home/danish/FastWorkspace/BDMA/TUB/flink-1.4.1-src/flink-1.4.1/build-target/"
FLINK=$FLINK_BUILD_PATH$"bin/flink"
JAR_PATH="/home/danish/FastWorkspace/BDMA/TUB/ds2/ds2/controller/running-examples/wordcount/1.4.1/flink-examples-1.0-SNAPSHOT-jar-with-dependencies.jar"
SOURCE_RATE_PATH="/home/danish/FastWorkspace/BDMA/TUB/ds2/ds2/controller/running-examples/wordcount/source_rates/source-rates.csv"

### dataflow configuration ###
QUERY_CLASS="ch.ethz.systems.strymon.ds2.flink.wordcount.StatefulWordCount"
SOURCE_NAME="Source: Custom Source"
MAP_NAME="Splitter FlatMap"
COUNT_NAME="Count -> Latency Sink"

### operators and parallelism
if [ "$1" == "" ]; then
    echo "Please provide operators and their initial parallelism"
    exit 1
fi

### parse operator pairs
IFS='#' read -r -a array <<< "$1"
for element in "${array[@]}"
do
    IFS=',' read -r -a parallelism <<< "$element"
        ## search for SOURCE_NAME
    if [ "${parallelism[0]}" == "$SOURCE_NAME" ]; then
        echo "Source parallelism: ${parallelism[@]: -1:1}"
        P_SOURCE="${parallelism[@]: -1:1}"
    fi
    ## search for FlatMap
    if [ "${parallelism[0]}" == "$MAP_NAME" ]; then
        echo "FlatMap parallelism: ${parallelism[@]: -1:1}"
        P1="${parallelism[@]: -1:1}"
    fi
    ## search for Count
    if [ "${parallelism[0]}" == "$COUNT_NAME" ]; then
        echo "Count parallelism: ${parallelism[@]: -1:1}"
        P2="${parallelism[@]: -1:1}"
    fi
done

RATES=`cat $SOURCE_RATE_PATH | grep -Eo "[0-9]+"`

nohup $FLINK run -d --class $QUERY_CLASS $JAR_PATH --p1 $P_SOURCE --p2 $P1 --p3 $P2 --source-rate $RATES --policy.rates.path /home/danish/FastWorkspace/BDMA/TUB/ds2/ds2/controller/running-examples/wordcount/metrics_repo/ & > job.out
