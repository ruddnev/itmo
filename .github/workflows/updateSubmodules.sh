#/bin/bash

token="$1"

touch newLastCommits.tmp

cat submoduleRepos.tmp | while read repoName; do 
    if [ -z "$repoName" ]; then 
        echo line is empty!
    else 
        sleep 5
        result=$(curl -s  -H "Authorization: token ${token}" -H "Accept: application/vnd.github.VERSION.sha" "https://api.github.com/repos/${orgName}/${repoName}/commits/main")
        echo "${repoName}: ${result}" >> newLastCommits.tmp
    fi; 
done; 

sort -o sortedNewLastCommits.tmp newLastCommits.tmp

rm newLastCommits.tmp
newLastCommits="sortedNewLastCommits.tmp"
lastCommits=".github/workflows/lastCommits.txt"
lastCommitsCount=0

if [ -f "$lastCommits" ]; then 
    lastCommitsCount=$(cat $lastCommits | wc -l)
fi

if [ "$lastCommitsCount" -gt "0" ]; then 
    if cmp --silent -- "$lastCommits" "$newLastCommits"; then 
        echo "no changes"
    else 
        git submodule update --recursive --remote
        cp $newLastCommits $lastCommits
        git commit -am "making submodules keep track of main branch"
        git push
    fi
else 
    cp $newLastCommits $lastCommits
    git add $lastCommits
    git commit -m "updating last commits"
    git push
fi
