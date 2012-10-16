#!/usr/bin/env lua

-- program: can you read the text if you were limited to the top N words in the array

require "wordlib"

word_dictionary = {} -- for quick lookup to see if the word exists

-- read in the csv file for word frequency
-- first column is the word, the second column is the number of times the word occurred
-- the returned table is reverse sorted by frequency, 
-- the first entry will have the word with the highest frequency
-- RETURNS the table as an array, the value is a table which has a "word" field and a "frequency" field
-- this makes it easy to sort
function read_word_frequency(filename)
   local word_data_list = {} -- what we will be returning
   local old_file = io.input() -- save current file
   local word_file = assert(io.open(filename, "r"))
   io.input(word_file)
   local line
   for line in io.lines() do
      -- split up the line with the comma
      local _word , _freq = string.match(line, "([^,]*),([^,]*)")
      local word_data = { word=_word, freq=tonumber(_freq) }
      --print ("word=" .. word_data.word .. ", freq=" .. word_data.freq .. ", type=" .. type(word_data.freq))
      if word_data ~= nil and word_data.word ~= nil and word_data.freq ~= nil then
	 table.insert(word_data_list, word_data)
      end
   end
   io.input().close() -- close current file
   io.input(old_file) -- restore to old file

   -- now we do a reverse sort
   table.sort(word_data_list, function(a,b) return a.freq > b.freq end)

   return word_data_list
end


function main_code()
   local filename = arg[1]
   local num_words = tonumber(arg[2])

   if num_words == nil then
      print("usage: " .. arg[0] .. " <words_file> <num_words>")
      os.exit()
   end

   -- process the word frequency csv file
   local word_data_list = read_word_frequency(filename)

   -- place the top words into the word_dictionary
   for i,word_data in ipairs(word_data_list) do
      word_dictionary[word_data.word] = true
      if i > num_words then
	 break
      end
   end

   -- read the text we are analyzing from 
   local line
   for line in io.lines() do
      local printline = ""
      for word in string.gmatch(line, "[^%s]+") do
	 local normalized_word = wordlib.normalize_word(word)
	 
	 if not normalized_word then
	    normalized_word = string.lower(word) -- may as well try to look it up
	    sexp = "!!"
	 else
	    sep = "??"
	 end

	 -- look up the word
	 if word_dictionary[normalized_word] then
	    -- found word
	    printline = printline .. word .. " "
	 else
	    -- word was not found in dictionary
	    printline = printline .. sep .. word .. sep .. " "
	 end
      end
      print(printline)
   end
end

main_code()
--for i,v in ipairs(word_list) do
--   print ("index=" .. i .. ", word=" .. v)
--end

