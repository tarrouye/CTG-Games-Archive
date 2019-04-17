gamecenter = {
  enabled = function() 
    return true
  end,
  
  submitScore = function(num, name)
    print("Submitted GameCenter score for ID: " .. name .. " : " .. num)
  end
}
