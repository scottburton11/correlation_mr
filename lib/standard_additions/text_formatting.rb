module TextFormatting
  def title(string)
    border = "=" * string.length
    puts "\n" + border + "\n" + string + "\n" + border + "\n\n"
  end

  def description(string, width = 80)
    words = string.split(/\s/)
    output = ""
    lines = [""]
    line_count = 0
    words.each do |word|
      lines[line_count] << word + " "
      if lines[line_count].length > width
        line_count += 1
        lines[line_count] = ""
      end
    end
    puts lines.join("\n") + "\n\n"
  end
end