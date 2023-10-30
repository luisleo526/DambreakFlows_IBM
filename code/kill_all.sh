#!/bin/bash

kill $(ps aux | grep '[R]UN' | awk '{print $2}')