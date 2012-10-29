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
   local output_missed = arg[1]
   local num_words = tonumber(arg[2])
   local word_filename = arg[3]
   local word_override_filename = arg[4]

   if num_words == nil then
      print("usage: " .. arg[0] .. " --output_missed=[true|false] <num_words> <words_file.csv> <words_override.csv>")
      os.exit()
   end

   -- process the word frequency csv file
   local word_data_list = read_word_frequency(word_filename)

   local word_override_list = nil
   if word_override_filename then
      word_override_list = read_word_frequency(word_override_filename)
   else
      word_override_list = {}
   end

   -- place the top words into the word_dictionary
   for i,word_data in ipairs(word_data_list) do
      word_dictionary[word_data.word] = true
      if i > num_words then
	 break
      end
   end
   for i,word_data in ipairs(word_override_list) do
      word_dictionary[word_data.word] = true
   end


   -- add all the words in words_file2

   -- read the text we are analyzing from 
   local missed_words = {} -- the words that were NOT in our dictionary and their count
   local line
   for line in io.lines() do
      local printline = ""
      for word in string.gmatch(line, "[^%s]+") do
	 local normalized_word = wordlib.normalize_word(word)
	 
	 if not normalized_word then
	    normalized_word = string.lower(word) 
	    -- may as well try to look it up
	    -- we set sep to '!!' to basically say that if we didn't find it, it could be because we 
	    -- couldn't parse the word, rather than it wasn't in our dictionary.  perhaps it wasnt 
	    -- even a word.
	    sep = "!!" 
	 else
	    -- if we didn't find the world, its clearly just not in the dictionary since we parsed it ok
	    sep = "??"
	 end

   --[[
	 -- look up the word
	 if word_dictionary[normalized_word] then
	    -- found word
	    printline = printline .. word .. " "
	 else
	    -- word was not found in dictionary
	    printline = printline .. sep .. word .. sep .. " "
         end
   --]]

	 -- look up the word
	 if not word_dictionary[normalized_word] then
	    -- add to the missed_words dictionary
	    if missed_words[normalized_word] then
	       missed_words[normalized_word] = missed_words[normalized_word] + 1
	    else
	       missed_words[normalized_word] = 1
	    end
         end
      end -- matches for each word
   end -- matches for each line
   
   -- print out all the missed words
   for miss_word,miss_count in pairs(missed_words) do
      print (miss_word .. "," .. miss_count)
   end
end

main_code()
--for i,v in ipairs(word_list) do
--   print ("index=" .. i .. ", word=" .. v)
--end

