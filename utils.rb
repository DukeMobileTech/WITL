# Strip leading & trailing whitespaces & replace curly with straight quotes
def sanitize(string)
  string.strip.gsub(/[\u2018\u2019\u201c\u201d]/, '\'')
end

# Generate new data headers for every variable and return list of new variables 
def generate_headers(data_headers, variables)
  headers = []
  variables.each do |var|
    headers << data_headers.map { |elem| elem + "_#{var}" }
  end
  headers.flatten!
end

# Write the data rows into the csv file using the given mode
def write_to_csv(file, mode, rows)
  CSV.open(file, mode) do |csv|
    rows.each do |row|
      csv << row
    end
  end
end

# Remove the leading question number characters from the string
# for example "Q70. " from the string "Q70. I feel CALM."
def strip_question_number(string)
  /\d/.match(string[1]) ? string.slice(string.index(" ")..-1).strip : string
end

# Create hash of variable_name (key) and question text (value) from csv file
def generate_variables(file)
  hash = Hash.new
  CSV.foreach(file, headers: true) do |row|
    if row[1] && row[3]
      hash[row[2].strip] = "#{row[0].strip}-Y"
    elsif row[1]
      hash[row[2].strip] = "#{row[0].strip}-#{row[1].strip}"
    elsif row[3]
      hash[row[2].strip] = "#{row[0].strip}-#{row[3].strip}"
    else
      hash[row[2].strip] = row[0].strip
    end
  end
  hash
end
