#!/usr/bin/env lua

require "wordlib"

-- table of the words we see and how often we saw a word
wordFreq = {}

-- table of lines we've seen, sometimes headlines for articles are shown over and over again
-- in other articles.  keep track of lines we've seen so if its repeated later, we don't count it twice
linesCache = {}

function process_line(line) 
   -- lowercase the line
   line = string.lower(line)
   
   -- have we seen this line?
   if linesCache[line] == nil then
      linesCache[line] = true
      
      -- get the words out of the line
      for word in string.gmatch(line, "[^%s]+") do
	 local normalized_word = wordlib.normalize_word(word)
	 if normalized_word then
	    if wordFreq[normalized_word] == nil then
	       wordFreq[normalized_word] = 0
	    end
	    wordFreq[normalized_word] = wordFreq[normalized_word]+1
	 end
      end
   end
end


for line in io.lines() do
   process_line(line)
end

for k,v in pairs(wordFreq) do
   print(k .. "," .. v)
end

