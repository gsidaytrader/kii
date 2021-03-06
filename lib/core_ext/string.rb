class String
  # Replacements for pretty URL encoding. `[["unencoded", "encoded"], ...]`.
  URL_ENCODE_CHARACTERS = [[" ", "_"]]
  
  def to_permalink
    copy = self.dup
    URL_ENCODE_CHARACTERS.each {|source, target| copy.gsub!(source, target) }
    copy
  end
  
  def from_permalink
    copy = self.dup
    URL_ENCODE_CHARACTERS.each {|target, source| copy.gsub!(source, target) }
    copy
  end
  
  def upcase_first_letter
    "#{self[0..0].upcase}#{self[1..-1]}"
  end
end