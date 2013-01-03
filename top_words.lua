#!/usr/bin/env lua

-- program: outputs the top N words from the frequency csv file

require "wordlib"

function usage_error()
   print("usage: " .. arg[0] .. " <num_words> <words_file.csv>")
   os.exit()
end

function main_code()
   local num_words = tonumber(arg[1])
   local word_filename = arg[2]
   
   if #arg ~= 2 then
      usage_error()
   end
   if num_words == nil then
      usage_error()
   end
   if word_filename == nil then
      usage_error()
   end

   -- process the word frequency csv file
   local word_data_list = wordlib.read_word_frequency(word_filename)
   for i,word_data in ipairs(word_data_list) do
      print (word_data.word)
      if i > num_words then
	 break
      end
   end
end

main_code()
