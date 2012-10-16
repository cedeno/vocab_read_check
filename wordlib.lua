module(..., package.seeall);

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
