#!/usr/bin/bash

find . -name "*.xml" > all_tool_files.txt
sed -i '/\/creators\.xml/d' all_tool_files.txt
sed -i '/\/tests\.xml/d' all_tool_files.txt
sed -i '/\/macros\.xml/d' all_tool_files.txt
sed -i '/\/macros\.xml/d' all_tool_files.txt
sed -i '/\/test-data/d' all_tool_files.txt

echo "Year | Added Tools | Updated Tools"
echo "-----|-------------|--------------"

tool_files=$(cat all_tool_files.txt)

declare -A added
declare -A updated

for tool in $tool_files; do

    # Get the first commit (added)
    add_year=$(git log --diff-filter=A --format="%ad" --date=format:'%Y' -- "$tool" | tail -n 1)

    # Get the years it was updated
    update_years=$(git log --diff-filter=M --format="%ad" --date=format:'%Y' -- "$tool" | sort -u)

    # Mark as added
    if [[ ! -z $add_year ]]; then
        added[$add_year]="${added[$add_year]}$(basename $tool), "
    fi

    # Mark as updated (after added year)
    for year in $update_years; do
        # Only mark as updated if not the added year
        if [[ "$year" != "$add_year" ]]; then
            updated[$year]="${updated[$year]}$(basename $tool), "
        fi
    done
done

# Get all years when any add/update happened, sort them
all_years=$(printf "%s\n" "${!added[@]}" "${!updated[@]}" | sort -u)

# Print the table
for year in $all_years; do
    add_list=${added[$year]:-}
    upd_list=${updated[$year]:-}
    #echo "$year | ${add_list%, } | ${upd_list%, }"
    add_count=$(echo "$add_list" | tr ', ' '\n' | grep -v '^$' | sort -u | wc -l)
    upd_count=$(echo "$upd_list" | tr ', ' '\n' | grep -v '^$' | sort -u | wc -l)
    echo "$year | $add_count | $upd_count"
done
