# frozen_string_literal: true

require_relative 'linter_service'

class Linter::JavascriptService < LinterService
  private

  def bash_command = "yarn run eslint #{@tmp_dir_path} -f json -c eslint.config.mjs"

  def process_data(result, parsed_result)
    files_with_errors = parsed_result.filter { |file| file['messages'].any? }

    return result if files_with_errors.empty?

    filename_separator = "#{@tmp_dir_path.to_s.split('/')[-3..].join('/')}/"
    files_with_errors.each do |file|
      filename = file['filePath'].split(filename_separator).last
      result[:files][filename] = []

      file['messages'].each do |message|
        error_data = {
          message: message['message'],
          cop_name: message['ruleId'] || '-',
          start_line: message['line'],
          start_column: message['column']
        }

        result[:files][filename] << error_data
        result[:offenses_count] += 1
      end
    end
    result
  end
end
