# frozen_string_literal: true

class RepositoryCheckService
  def initialize(check)
    @check = check
    @repository = @check.repository
    @github_client = ApplicationContainer[:github_client].new(@repository)
    @tmp_dir_path = Rails.root.join('tmp', 'repositories', @repository.id.to_s)
    @bash_runner = ApplicationContainer[:bash_runner]
    @linter_service = linter_service(@repository)
  end

  def call
    return unless @linter_service

    check_repo
  rescue StandardError
    @check.mark_as_failed!
  ensure
    CheckResultMailer.with(user: @repository.user, repository: @repository, check: @check).result_email.deliver_later
  end

  private

  def check_repo
    @check.run_check!
    @check.update(commit_id: @github_client.last_commit_sha)

    lint_repo
    @check.mark_as_finished!
  end

  def clone_repo
    FileUtils.mkdir_p(@tmp_dir_path)
    FileUtils.rm_rf(@tmp_dir_path) if Dir.exist?(@tmp_dir_path) && !Dir.empty?(@tmp_dir_path)

    bash_command = "git clone #{@repository.clone_url} #{@tmp_dir_path}"

    @bash_runner.run(bash_command)
  end

  def lint_repo
    clone_repo

    @linter_service.new(@check, @tmp_dir_path).call
    FileUtils.rm_rf(@tmp_dir_path)
  end

  def linter_service(repo) = "Linter::#{repo.language.capitalize}Service".constantize
end
