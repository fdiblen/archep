#!/bin/bash

time docker build -t fdiblen/archep:base -t fdiblen/archep:latest .
# docker push fdiblen/archep:latest
# docker push fdiblen/archep:base
