#!/usr/bin/env lua

-- program: can you read the text if you were limited to the top N words in the array

word_list = {} -- we read the list of words directly here as an array
word_dictionary = {} -- for quick lookup to see if the word exists

-- we get in a raw word, may not be fully alpha numeric or lowercased
-- normalize the word, see if we can get the punctuation out
-- return the normalized word or nil if it cant be normalized
function normalize_word(word)
   local prefix = string.lower(word)

   -- if its a full number, then just return it
   if string.match(prefix, "^%d+$") then
      return prefix
   end
   
   -- remove prefix and trailing punctuation
   local a,no_punctuation,c =  string.match(prefix, "^([%[%]%(%)\"“”]*)([^%(%)%[%],.!?\"“”:]+)([%(%)%[%],.!?\"“”:]*)$")
   if a ~= "" or c ~= "" then
     print (prefix .. "->" .. no_punctuation)
   end
   if no_punctuation ~= nil then
      prefix = no_punctuation
   end

   -- if its not alpha then return it in brackets since we cant look it up
   if not string.match(prefix, "^[a-z]+$") then
      -- print ("word is not full alpha: '" .. prefix .. "'")
      return nil
   end

   return prefix
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
	 local normalized_word = normalize_word(word)
	 
	 if not normalized_word then
	    normalized_word = string.lower(word) -- may as well try to look it up
	    sep = "!!"
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

