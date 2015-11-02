#!/bin/bash

mkdir -p _temp
rm -rf _temp/words.txt
echo -n "fetching all words... "
for f in $(find _site -name '*.html'); do
  tidy -i -asxml $f 2>/dev/null | \
    sed "s|>|>\n|g" | \
    xmllint -html -xpath '(//article//p|//article//h2|//article//h3|//article//h4)/text()' - 2>/dev/null | \
    sed "s/[^a-zA-Z]/ /g" | \
    tr A-Z a-z | \
    sed 's/[ \t\n]/\n/g' | \
    sed '/^[ \t]*$/d' >> _temp/words.txt
done
echo -e "done, $(wc -l _temp/words.txt | cut -f1 -d ' ') words found"

rm -rf _temp/good-words.txt
echo -n "removing stop words... "
cat _temp/words.txt | sort | uniq -c | sort -r | cut -c9- | \
while read k; do
  grep -q $k _test/stop-words.txt
  if [[ $? != 0 ]]; then
    echo $k >> _temp/good-words.txt
  fi
done
echo "done, $(wc -l _temp/good-words.txt | cut -f1 -d ' ') good words left"

cat _temp/good-words.txt | head -200 > _temp/top-words.txt

while read k; do
  echo -n "${k}: "
  grep -q $k _temp/top-words.txt
  if [[ $? = 1 ]]; then
    echo "is absent!"
    exit -1
  fi
  echo "OK"
done < _test/core-keywords.txt

