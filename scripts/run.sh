#!/usr/bin/bash

# author: hoelzer.martin@gmail.com

# Run all scripts to get publication markdown files for further processing

for MEMBER in martin hugues matt; do

    ## use the SERPAPI to get the scholar content 
    #python scrap.py config-${MEMBER}.yml 

    ## convert the obtained json file to markdown per team member
    ruby js2md.rb $MEMBER config-${MEMBER}.yml config-${MEMBER}.json

    ## mv the resulting md files to the docs/team folder
    mv ${MEMBER}.publications.md ../docs/team/

    ## the GitHub CI Action will then automatically add the content from these md files to the individual team pages

done

## combine everything into a team publication file, only include pubs from 2020 onward 
ruby js2md-all.rb 
cp publications.md ../docs/
