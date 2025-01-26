# frozen_string_literal: true

class LinterService
  def initialize(check, tmp_dir_path)
    @check = check
    @tmp_dir_path = tmp_dir_path
    @bash_runner = ApplicationContainer[:bash_runner]
  end

  def call
    bash_output = @bash_runner.run(bash_command)
    data = bash_output.nil? ? {} : JSON.parse(bash_output)

    linter_check_result = process_data({ offenses_count: 0, files: {} }, data)

    @check.update(linter_check_result:, passed: linter_check_result[:offenses_count].zero?)
  end

  private

  def bash_command
    raise NotImplementedError
  end

  def proccess_data(result, data)
    raise NotImplementedError
  end
end
