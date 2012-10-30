Set of scripts to download content from NYTimes and Foxnews for vocabulary analysis.

First you will need to get the site content, I used wget to make this happen

Here is an explanations of the wget options I used:
- -l 2 says follow 2 levels deep
- -I 2012 is specific to NYTimes - it says to only include stuff in the 2012 directory which are articles otherwise we get a bunch of random website stuff 
- -w 2 says to wait for 2 seconds between each retrieval

To run:

    wget -r -l 3 -I 2012 -w 2 http://www.nytimes.com/most-popular
    wget -r -l 3 -w 2 http://www.foxnews.com

You will now have a www.foxnews.com and www.nytimes.com directories.

execute iterate_nytimes.sh and iterate_fox.sh to process all the HTML 
content and turn it into straight text, which is much easier to process.
we use 'lynx' to do this, a text-based web browser, so you may need to 
yum install lynx

you need to direct output

    $ ./iterate_fox.sh > FOX_OUT

word_check.lua (requires lua) will read the words in and count individual
words.  it discounts 'words' that have non-alpha characters in it.
the output will be in csv format.  the word followed by a comma followed by
the number of occurrences. you can import this into a spreadsheet.

    $ ./word_check.lua < FOX_OUT > FOX_OUT.csv

---

How much of an article can you read with the most popular vocabulary words?
Using ./read_check.lua, you pipe in a piece of text (eg: news article, blog post), give it the csv file you just generated with word_check.lua and also tell it the number of top occurring words you want to use (ie, if you pass in 5, it will check words in the article against the top 5 occurring words in the csv, which is probably 'the', 'an', 'a', etc)

There's a lot of proper names in most stories, and its not fair to count these as misses.  Given content you usually know "Mr. Gropper gave the boy some roses", that Mr. Gropper is a person.

To adjust for this, the script runs in two passes.  The first time you pass in "--output_missed=true" and it will output a csv to stdout which contains all the missing words and how often they missed.

For example:
./read_check.lua --output_missed=true 3000 ./data/foxnews.csv < ./data/article1.txt > ./data/article1_missed_words.txt

You can then edit the missed words file and leave only the 'exceptions'.  This will effectively add those words to the known dictionary without affecting the number of words we use in the primary dictionary file.

The second pass, you set --output_missed=false and also give this file , eg:
./read_check.lua --output_missed=false 3000 ./data/foxnews.csv ./data/article1_missed_words.txt < ./data/article1.txt


