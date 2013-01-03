module(..., package.seeall);

-- read in the csv file for word frequency
-- first column is the word, the second column is the number of times the word occurred
-- the returned table is reverse sorted by frequency, 
-- the first entry will have the word with the highest frequency
-- RETURNS the table as an array, each element in array is a table which has a "word" field and a "frequency" field.  
--   this makes it easy to sort with table.sort()
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
   local a,no_punctuation,c =  string.match(prefix, "^([%[%]%(%)\"“”'`]*)([^%(%)%[%],.!?\"“”:]+)([%(%)%[%],.!?\"“”:]*)$")
   if a ~= "" or c ~= "" then
      --print (prefix .. "->" .. no_punctuation)
   end
   if no_punctuation ~= nil then
      prefix = no_punctuation
   end

   -- the single quote was allowed in the word, which makes things tricky because it could be used
   -- as a quote(something someone said) or it could be a contraction.  real quotes show up at the end
   -- so we check for that case
   -- eg: .... and then I slapped him.'
   local quote_body = string.match(prefix, "^(.+)'$") 
   if quote_body then
      prefix = quote_body
   end

   -- now check if it looks like a contraction
   local contraction_base = string.match(prefix, "([a-z]+)'[a-z]+")
   if contraction_base then
      --print ("contraction: " .. prefix .. " -> " .. contraction_base)
      return prefix
   end

   -- if its not alpha
   -- then return it in brackets since we cant look it up
   if not string.match(prefix, "^[a-z]+$") then
      --print ("word is not full alpha: '" .. prefix .. "'")
      return nil
   end

   return prefix
end

-- returns a randomly generated word
function create_random_word()
   local word_len = math.random(7) + 3
   local word = ""
   for i=1,word_len do
      if (i % 2) == 1 then
	 word = word .. consonant()
      else
	 word = word .. vowel()
      end
   end
   return word
end

consonants = "bcdfghjklmnpqrstvwxyz"
consonants_len = string.len(consonants)
vowels = "aeiou"
vowels_len = string.len(vowels)

function consonant()
   local random_index = math.random(consonants_len)
   letter = string.sub(consonants, random_index, random_index)
   return letter
end

function vowel()
   local random_index = math.random(vowels_len)
   letter = string.sub(vowels, random_index, random_index)
   return letter
end
