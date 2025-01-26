# frozen_string_literal: true

require_relative 'linter_service'

class Linter::RubyService < LinterService
  private

  def bash_command = "bundle exec rubocop #{@tmp_dir_path} --format json -c .rubocop.yml"

  def process_data(result, parsed_result)
    offenses_count = parsed_result.dig('summary', 'offense_count') || 0

    return result if offenses_count.zero?

    result[:offenses_count] = offenses_count
    files_with_errors = parsed_result['files'].filter { |file| file['offenses'].any? }

    files_with_errors.each do |file|
      filename = file['path'].split('/')[3..].join('/')
      result[:files][filename] = []

      file['offenses'].each do |offense|
        error_data = {
          message: offense['message'],
          cop_name: offense['cop_name'],
          start_line: offense['location']['start_line'],
          start_column: offense['location']['start_column']
        }

        result[:files][filename] << error_data
      end
    end
    result
  end
end
