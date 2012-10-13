#!/usr/bin/env lua

-- program: can you read the text if you were limited to the top N words in the array

word_list = {} -- we read the list of words directly here as an array
word_dictionary = {} -- for quick lookup to see if the word exists

-- we get in a raw word, may not be fully alpha numeric or lowercased
-- normalize the word, see if we can get the punctuation out,
-- and if we match a word then return it, otherwise return gobbledy-gook
-- if we can't make sense of it (numbers or something) then put it in brackets and return it
function process_word(word)
   local prefix = string.lower(word)

   -- if its a full number, then just return it
   if string.match(prefix, "^%d+$") then
      return prefix
   end
   
   -- remove prefix and trailing punctuation
   local a,no_punctuation,c =  string.match(prefix, "^([%[%]%(%)\"“”]*)([^%(%)%[%],.!?\"“”:]+)([%(%)%[%],.!?\"“”:]*)$")
   if a ~= "" or c ~= "" then
     -- print (prefix .. "->" .. no_punctuation)
   end
   if no_punctuation ~= nil then
      prefix = no_punctuation
   end

   -- if its not alpha then return it in brackets since we cant look it up
   if not string.match(prefix, "^[a-z]+$") then
      -- print ("word is not full alpha: '" .. prefix .. "'")
      return "[" .. word .. "]"
   end

   -- its fully alpha, see if we have it in our word list
   if word_dictionary[prefix] then
      return word
   else 
      return "<<" .. word .. ">>"
   end
   
end

function main_code()
   filename = arg[1]
   num_words = tonumber(arg[2])

   if num_words == nil then
      print("usage: " .. arg[0] .. " <words_file> <num_words>")
      os.exit()
   end

   -- read the words text file - we assume one word per line and in order, 
   -- the first word is the most common word
   local old_file = io.input() -- save current file
   local word_file = assert(io.open(filename, "r"))
   io.input(word_file)

   local word
   local i = 0
   for word in io.lines() do
      if i >= num_words then
	 break
      end
      table.insert(word_list, word)
      word_dictionary[word] = true
      i = i+1
   end
   io.input().close() -- close current file
   io.input(old_file) -- restore to old file

   -- read the text we are analyzing from 
   for line in io.lines() do
      printline = ""
      for word in string.gmatch(line, "[^%s]+") do
	 w = process_word(word)
	 printline = printline .. w .. " "
      end
      print(printline)
   end
end

main_code()
--for i,v in ipairs(word_list) do
--   print ("index=" .. i .. ", word=" .. v)
--end

