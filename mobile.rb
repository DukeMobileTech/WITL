require 'csv'

BASE_DIR = '../Mobile'
DATA_DIR = "#{BASE_DIR}/Data"
VARIABLE_NAMES_FILE = "#{BASE_DIR}/WITL_variable_names_Mobile.csv"
DATA_HEADERS = %w[ResultDeviceName ResultId SurveyName ResultSurveyedDate 
  ResultSurveyedEndDate ScreenResultAnswerDate ScreenText ScreenTypeName 
  ScreenResultAnswerText]
WIDE_DATA_FILE = "#{DATA_DIR}/mobile_wide.csv"
DATA_FILES = ["#{DATA_DIR}/A Week in the Life- Mobile Survey (1.2) 20151212_List_Comma.csv",
              "#{DATA_DIR}/A Week in the Life- Mobile Survey (1.3) 20151212_List_Comma.csv"]
  
variable_names_hash = Hash.new
CSV.foreach(VARIABLE_NAMES_FILE, headers: true, encoding:'iso-8859-1:utf-8') do |row|
  variable_names_hash[sanitize(row[3])] = sanitize(row[0])
end
headers = generate_headers(DATA_HEADERS, variable_names_hash.keys)
write_to_csv(WIDE_DATA_FILE, 'wb', [headers])
data = Hash.new
DATA_FILES.each do |filename|
  CSV.foreach(filename, headers: true, encoding: 'bom|utf-8') do |row|
    data_array = data[row[0].strip]
    unless data_array
      data_array = Array.new(headers.length)
    end
    text = strip_question_number(sanitize(row[6]))
    variable_key = variable_names_hash.key(text)
    DATA_HEADERS.each_with_index { |value, index|
      cell_index = headers.index("#{value}_#{variable_key}")
      data_array[cell_index] = row[index]
    }
    data[row[0].strip] = data_array
  end
end
write_to_csv(WIDE_DATA_FILE, 'a+', data.values)

BEGIN {
  # Remove leading and trailing whitespaces and replace curly quotes with straight quotes
  def sanitize(string)
    string.strip.gsub(/[\u2018\u2019\u201c\u201d]/, '\'')
  end
  
  def generate_headers(data_headers, variables)
    headers = []
    variables.each do |var|
      headers << data_headers.map { |elem| elem + "_#{var}" }
    end
    headers.flatten!
  end
  
  def write_to_csv(file, mode, rows)
    CSV.open(file, mode) do |csv|
      rows.each do |row|
        csv << row
      end
    end
  end
  
  def strip_question_number(string)
    /\d/.match(string[1]) ? string.slice(string.index(" ")..-1).strip : string
  end
  
}