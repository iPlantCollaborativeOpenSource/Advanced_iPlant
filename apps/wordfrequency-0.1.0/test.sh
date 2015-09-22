#!/bin/bash

# set test variables
export filename="--filename data/174.txt.utf-8"
export max_length="--max 24"
# Defined a boolean in the app description
export allow_digits="1"
export ignore_list="--ignore the,a,it,on,i,an,and,to,of"

# call wrapper script as if the values had been injected by the API
bash wrapper.sh
