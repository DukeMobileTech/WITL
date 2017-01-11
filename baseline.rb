require 'csv'

variables_file = '../Baseline/WITLvarnamesBaseline.csv'
variables_hash = generate_variables(variables_file)
data_file = '../Baseline/Data/A Week in the Life- Baseline Survey (1.0) 20151212_List_Comma.csv'
# Use bom-utf-8 encoding to avoid malformed csv errors
data_headers = CSV.read(data_file, headers: true, encoding: 'bom|utf-8').headers
combined_headers = generate_headers(data_headers, variables_hash)

baseline_wide = '../Baseline/Data/baseline_wide.csv'
CSV.open(baseline_wide, 'wb') do |csv|
  csv << combined_headers
end
    
data_array = Array.new(combined_headers.length)
CSV.foreach(data_file, headers: true, encoding: 'bom|utf-8') do |row|
  # Remove leading or trailing whitespaces and replace curly quotes with 
  # straight quotes in the text at index 6 for easier comparison
  text = row[6].strip.gsub(/[\u2018\u2019\u201c\u201d]/, '\'') 
  # Remove the question number from the text, for example "Q39. " 
  if /\d/.match(text[1])
    text = text.slice(text.index(" ")..-1).strip
  end
  # Find the variable identifying the row of data 
  data_values = [text, "#{text}-#{row[7].strip}", "#{text}-#{row[8].strip}", "#{text}-Y"]
  variable_key = nil
  data_values.each do |val|
    variable_key = variables_hash.key(val)
    break if variable_key
  end
  # Insert data in their indices within the csv row array 
  data_headers.each_with_index { |value, index|
    cell_index = combined_headers.index("#{value}_#{variable_key}")
    data_array[cell_index] = row[index]
  }

  # Write participant data to csv file once all surveys are in the row array
  if variable_key == 'id2'
    write_row(baseline_wide, data_array)
    data_array = Array.new(combined_headers.length)
  end
  
end

BEGIN {
  
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
  
  def generate_headers(data_headers, variables_hash)
    combined_headers = []
    variables_hash.keys.each do |key|
      combined_headers << data_headers.map { |elem| elem + "_#{key}" }
    end
    combined_headers.flatten!
  end
  
  def write_row(file, row)
    CSV.open(file, 'a+') do |csv|
      csv << row
    end
  end
  
}
