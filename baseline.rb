require 'csv'
require_relative 'utils'

BASE_DIR = '../Baseline'
DATA_DIR = "#{BASE_DIR}/Data"
VARIABLES_FILE = "#{BASE_DIR}/WITLvarnamesBaseline.csv"
DATA_FILE = "#{DATA_DIR}/A Week in the Life- Baseline Survey (1.0) 20151212_List_Comma.csv"
WIDE_DATA_FILE = '../Baseline/Data/baseline_wide.csv'
DATA_HEADERS = CSV.read(DATA_FILE, headers: true, encoding: 'bom|utf-8').headers

variables_hash = generate_variables(VARIABLES_FILE)
combined_headers = generate_headers(DATA_HEADERS, variables_hash.keys)
write_to_csv(WIDE_DATA_FILE, 'wb', [combined_headers])  

data = Hash.new 
data_array = nil
CSV.foreach(DATA_FILE, headers: true, encoding: 'bom|utf-8') do |row|
  text = strip_question_number(sanitize(row[6]))
  # Find the variable identifying the row of data 
  data_values = [text, "#{text}-#{row[7].strip}", "#{text}-#{row[8].strip}", "#{text}-Y"]
  variable_key = nil
  data_values.each do |val|
    variable_key = variables_hash.key(val)
    break if variable_key
  end
  # Check if start of survey
  if variable_key == 'id'
    data_array = data[row[8].strip]
    unless data_array
      data_array = Array.new(combined_headers.length)
    end
  end
  # Insert data in their indices within the csv row array 
  DATA_HEADERS.each_with_index { |value, index|
    cell_index = combined_headers.index("#{value}_#{variable_key}")
    data_array[cell_index] = row[index]
  }
  # Check if end of survey
  if variable_key == 'id2'
    data[row[8].strip] = data_array
  end
end
write_to_csv(WIDE_DATA_FILE, 'a+', data.values)
