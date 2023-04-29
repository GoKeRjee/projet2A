#!/bin/bash

# Use the sed command to replace placeholders in the template file
sed -e "s#<LOGO>#$1#g" -e "s#<HEADER>#$2#g" -e "s#<FOOTER>#$3#g" $4/template > $4/template.pug
