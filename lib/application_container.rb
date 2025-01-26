# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register(:github_client) { Github::FakeClient }
    register(:bash_runner) { FakeBashRunner }
  else
    register(:github_client) { Github::Client }
    register(:bash_runner) { BashRunner }
  end
end
