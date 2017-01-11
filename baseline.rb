require 'csv'

variables_file = '../Baseline/WITLvarnamesBaseline.csv'
variables_hash = generate_variables(variables_file)

baseline_data_file = '../Baseline/Data/A Week in the Life- Baseline Survey (1.0) 20151212_List_Comma.csv'
combined_headers = generate_headers(baseline_data_file, variables_hash)

baseline_wide = '../Baseline/Data/baseline_wide.csv'
CSV.open(baseline_wide, 'wb') do |csv|
  csv << combined_headers
end
    
data_array = Array.new(combined_headers.length)
CSV.foreach(baseline_data_file, headers: true, encoding: 'bom|utf-8') do |row|
  # Remove leading or trailing whitespaces and replace curly quotes with 
  # straight quotes in the text at index 6 for easier comparison
  text = row[6].strip.gsub(/[\u2018\u2019\u201c\u201d]/, '\'') 
  # Remove the question number from the text, for example "Q39. " 
  if /\d/.match(text[1])
    text = text.slice(text.index(" ")..-1).strip
  end
  # Find the variable representing the row of data 
  variable_key = variables_hash.key(text)
  unless variable_key
    variable_key = variables_hash.key(text + "-" + row[7].strip)
    unless variable_key
      variable_key = variables_hash.key(text + "-" + row[8].strip)
      unless variable_key
        variable_key = variables_hash.key(text + "-Y")
      end
    end
  end
  # Insert data in their indexes within the csv row array 
  device_index = combined_headers.index("ResultDeviceName_#{variable_key}")
  data_array[device_index] = row[0]
  id_index = combined_headers.index("ResultId_#{variable_key}")
  data_array[id_index] = row[1]
  name_index = combined_headers.index("SurveyName_#{variable_key}")
  data_array[name_index] = row[2]
  start_time_index = combined_headers.index("ResultSurveyedDate_#{variable_key}")
  data_array[start_time_index] = row[3]
  end_time_index = combined_headers.index("ResultSurveyedEndDate_#{variable_key}")
  data_array[end_time_index] = row[4]
  answer_date_index = combined_headers.index("ScreenResultAnswerDate_#{variable_key}")
  data_array[answer_date_index] = row[5]
  text_index = combined_headers.index("ScreenText_#{variable_key}")
  data_array[text_index] = row[6]
  type_name_index = combined_headers.index("ScreenTypeName_#{variable_key}")
  data_array[type_name_index] = row[7]
  answer_index = combined_headers.index("ScreenResultAnswerText_#{variable_key}")
  data_array[answer_index] = row[8]

  # Write participant data to csv file once all surveys are in the csv row array
  if variable_key == 'id2'
    write_row(baseline_wide, data_array)
    #Create new data row for the next participant
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
  
  def generate_headers(file, variables_hash)
    # Use bom-utf-8 encoding to avoid malformed csv errors
    data_headers = CSV.read(file, headers: true, encoding: 'bom|utf-8').headers
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
