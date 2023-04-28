#!/bin/bash

# Use the sed command to replace placeholders in the template file
sed -e "s#<LOGO>#$LOGO#g" -e "s#<HEADER>#$HEADER#g" -e "s#<FOOTER>#$FOOTER#g" template > template.pug
