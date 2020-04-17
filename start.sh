#!/bin/sh

docker run -ti --rm --net="host" --name archep_test fdiblen/archep $@
