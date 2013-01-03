#!/usr/bin/env lua

-- program: can you read the text if you were limited to the top N words in the array

require "wordlib"

word_dictionary = {} -- for quick lookup to see if the word exists
output_missed_flag = false -- this flag indicates whether to output the missed words as a csv

function usage_error()
      print("usage: " .. arg[0] .. " --output_missed=[true|false] <num_words> <words_file.csv> <words_override.csv>")
      os.exit()
end

function main_code()
   local output_missed_arg = arg[1]
   local num_words = tonumber(arg[2])
   local word_filename = arg[3]
   local word_override_filename = arg[4]

   if output_missed_arg == nil then
      usage_error()
   end
   if string.match(output_missed_arg, "true$") then
      output_missed_flag = true
   else
      output_missed_flag = false
   end

   if num_words == nil then
      usage_error()
   end

   -- process the word frequency csv file
   local word_data_list = wordlib.read_word_frequency(word_filename)

   local word_override_list = nil
   if word_override_filename then
      word_override_list = wordlib.read_word_frequency(word_override_filename)
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

   -- read the text we are analyzing from 
   local missed_words = {} -- the words that were NOT in our dictionary and their count

   -- mapping of missed words to their fake word equivalent (so we use the same fake word 
   -- again each time we see a particular missed word
   local fake_words = {} 

   local line
   for line in io.lines() do
      local printline = ""
      for word in string.gmatch(line, "[^%s]+") do
	 local normalized_word = wordlib.normalize_word(word)
	 local sep = "" -- separator for missed word

	 if not normalized_word then
	    normalized_word = string.lower(word) 
	    -- may as well try to look it up
	    -- we set sep to '!!' to basically say that if we didn't find it, it could be because we 
	    -- couldn't parse the word, rather than it wasn't in our dictionary.  perhaps it wasnt 
	    -- even a word.
	    --sep = "!!" 
	 else
	    -- if we didn't find the world, its clearly just not in the dictionary since we parsed it ok
	    --sep = "??"
	 end

	 -- look up the word
	 if word_dictionary[normalized_word] then
	    -- found word
	    printline = printline .. word .. " "
	 else
	    -- word was not found in dictionary

	    -- add to the missed_words dictionary
	    if missed_words[normalized_word] then
	       missed_words[normalized_word] = missed_words[normalized_word] + 1
	    else
	       missed_words[normalized_word] = 1
	    end

	    local fake_word = fake_words[normalized_word]
	    if not fake_word then
	       fake_word = wordlib.create_random_word()
	       fake_word = string.upper(fake_word)
	       fake_words[normalized_word] = fake_word
	    end

	    -- construct printline
	    printline = printline .. sep .. fake_word .. sep .. " "
	 end
      end -- matches for each word

      if not output_missed_flag then
	 print (printline)
      end
   end -- matches for each line
   
   -- print out all the missed words
   if output_missed_flag then
      for miss_word,miss_count in pairs(missed_words) do
	 print (miss_word .. "," .. miss_count)
      end
   end
end

main_code()
--for i,v in ipairs(word_list) do
--   print ("index=" .. i .. ", word=" .. v)
--end

