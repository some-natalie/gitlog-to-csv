#!/bin/bash

# This script generates a CSV file with the git history of the repository.
# Run from the project's root directory.

# set environment variables
# COMMIT_URL="${{ github.server_url }}/${{ github.repository }}/commit/"
COMMIT_URL=""  # makes a nice, clickable link to the commit in the CSV
input_gpg="true"  # whether to include GPG signature information
input_diffs="true"  # whether to create a diff file for each commit

# git log
if [ $input_gpg = "true" ]; then
  git log main --date=local --pretty="%x40%H%x2C%h%x2C%an%x2C%G?%x2C%GS%x2C%GK%x2C%ad%x2C%x22%s%x22%x2C" --shortstat | tr "\n" " " | tr "@" "\n" >> log.csv
else
  git log main --date=local --pretty="%x40%H%x2C%h%x2C%an%x2C%ad%x2C%x22%s%x22%x2C" --shortstat | tr "\n" " " | tr "@" "\n" >> log.csv
fi

# sed magic to remove text from number fields
sed -i.bak 's/ files changed//' log.csv
sed -i.bak 's/ file changed//' log.csv
sed -i.bak 's/ insertions(+)//' log.csv
sed -i.bak 's/ insertion(+)//' log.csv
sed -i.bak 's/ deletions(-)//' log.csv
sed -i.bak 's/ deletion(-)//' log.csv

# download diffs if needed
if [ $input_diffs = "true" ]; then
  sed -i.bak -e "1d" log.csv  # delete blank line at the top
  initial_commit_id=$(git rev-list --max-parents=0 HEAD)  # get the initial commit id
  initial_commit_short_id=$(git rev-list --max-parents=0 HEAD | cut -c 1-7)  # get the initial commit short id
  git show "$initial_commit_id" > "$initial_commit_short_id".diff  # write the first diff to the file
  while read -r line; do  # loop through the rest of the diffs
    commit_id=$(echo "$line" | awk -F"," '{print $1}')
    short_commit_id=$(echo "$line" | awk -F"," '{print $2}')
    git show "$commit_id" > "$short_commit_id".diff
  done < log.csv
fi

# awk to insert the commit url to click and view the diff
awk -F"," 'OFS = ", " {$1 = "'"$COMMIT_URL"'"$1; print}' log.csv > history.csv

# now add that header row
if [ $input_gpg = "true" ]; then
  sed -i.bak '1s/.*/url,commit id,author,commit signature status,name of signer,key used to sign,date,comment,changed files,lines added,lines deleted/' history.csv
else
  sed -i.bak '1s/.*/url,commit id,author,date,comment,changed files,lines added,lines deleted/' history.csv
fi

# clean up
rm log.csv
rm log.csv.bak
rm history.csv.bak
