---
title: "Bash Scripting to Rename Files Removing Part of Their Name"
date: 2025-07-29
draft: false
tags: ["dev", "bash", "regex"]
categories: ["scripting"]
description: "Get rid of date strings in file names using regex in a Bash script"
---

Having moved from open source blog and newsletter platform [Ghost](https://ghost.org/) for a better suited static site generator, (Hugo)[https://gohugo.io/], I had to export articles published or drafted in Ghost to markdown in order to use republished them on my new blog.
That was a non-issue as Ghost allows to export to an archive of JSON files and one can then use [ghost-to-md](https://github.com/hswolff/ghost-to-md) to export your content to a series of Markdown files.  

The issue is that these files contain unnecessary date string in their file names. So I had to write a small script to use regex and get rid of these.
Here it is in a single command line to be ran inside the directory containing your *.md* files:  
  `for file in *; do basename=$(basename "$file") && new_name=$(echo "$basename" | sed 's/^[0-9]\+-[0-9]\+-[0-9]\+-//') && mv "$file" "$new_name"; done`  
Otherwise here is a [script](https://gist.github.com/CacteGra/cef1d979eb5fab8a17b04aed82bc8581) to run anywhere when providing the directory path, that makes sure the file is a file and it will not be renamed to an empty string.
```bash
  #!/bin/bash
  for file in "$DIR"/*; do new_name=$(echo "$basename" | sed 's/^[0-9]\+-[0-9]\+-[0-9]\+-//'); done
  # Script to remove date prefixes like "0-0-0-" or in the case of date formatting "0000-00-00" from filenames
  # Run sh this_script.sh inside the targeted directory
  
  # Set directory to current directory if not provided
  DIR="${1:-.}"
  
  # Check if directory exists
  if [ ! -d "$DIR" ]; then
      echo "Error: Directory '$DIR' does not exist."
      exit 1
  fi
  
  # Counter for total renamed files
  count=0
  
  # Looping files inside the specified directory
  for file in "$DIR"/*; do
      # Skip if not a file
      [ ! -f "$file" ] && continue
      
      # Get just the filename without path
      basename=$(basename "$file")
      
      # Check if filename starts with pattern like "0000-00-00-"
      # This regex matches: digits-digits-digits- at the start
      if [[ $basename =~ ^[0-9]+-[0-9]+-[0-9]+- ]]; then
          new_name=$(echo "$basename" | sed 's/^[0-9]\+-[0-9]\+-[0-9]\+-//')
          # sed 's/original_string/replaced_string', in this case the string is replaced by emptiness
          # ^ character means the file name has to begin with the pattern that follows
          
          # Get the directory path
          dir_path=$(dirname "$file")
          
          # Create new full path
          new_path="$dir_path/$new_name"
          
          # Check if new filename would be empty
          if [ -z "$new_name" ]; then
              echo "Warning: Skipping '$basename' - would result in empty filename"
              continue
          fi
          
          # Check if target file already exists
          if [ -e "$new_path" ]; then
              echo "Warning: Skipping '$basename' - target '$new_name' already exists"
              continue
          fi
          
          # Rename the file
          if mv "$file" "$new_path"; then # True if file moved to new name
              echo "Renamed: '$basename' → '$new_name'"
              ((count++))
          else
              echo "Error: Failed to rename '$basename'"
          fi
      fi
  done
  
  echo "Completed. Renamed $count files."
```

