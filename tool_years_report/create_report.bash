#!/usr/bin/bash

export SCRIPTDIR=$(dirname 0)
export ROOTDIR=$SCRIPTDIR/..
export TOOLLISTFILE=$ROOTDIR/all_tool_files.txt

find $ROOTDIR -name "*.xml" > $TOOLLISTFILE
sed -i '/\/creators\.xml/d' $TOOLLISTFILE
sed -i '/\/tests\.xml/d' $TOOLLISTFILE
sed -i '/\/macros\.xml/d' $TOOLLISTFILE
sed -i '/\/macros\.xml/d' $TOOLLISTFILE
sed -i '/\/test-data/d' $TOOLLISTFILE

echo "Year | Added Tools | Updated Tools"
echo "-----|-------------|--------------"

tool_files=$(cat $TOOLLISTFILE)

declare -A added
declare -A updated

for tool in $tool_files; do
    export tool_rootdir=$(dirname "$tool")

    # Get the first commit (added)
    add_year=$(git log --diff-filter=A --format="%ad" --date=format:'%Y' -- "$tool_rootdir" | tail -n 1)

    # Get the years it was updated
    update_years=$( \
        git log --diff-filter=M --format="%H;%ad" --date=format:'%Y' -- "$tool_rootdir" \
        | grep -v -f $SCRIPTDIR/excluded_commits.txt \
        | cut -d';' -f2 \
        | sort -u \
    )

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
    if [[ "$1" == "--sum" ]]; then
        add_count=$(echo "$add_list" | tr ', ' '\n' | grep -v '^$' | sort -u | wc -l)
        upd_count=$(echo "$upd_list" | tr ', ' '\n' | grep -v '^$' | sort -u | wc -l)
        echo "$year | $add_count | $upd_count"
    else
        echo "$year | ${add_list%, } | ${upd_list%, }"
    fi
done
