source 'https://rubygems.org'

# NOTE: Relying on the controlrepo gem in jenkins will end up with over 100 gems
# installed as dependencies.  When running in CI, this can be unnecessarily time
# consuming, especially if only RSpec tests are being exercised.  Consuder using
# the controlrepo gem when integration and system level tests are exericsed, but
# for now I recommend only using it in development, not when testing in CI.

group :development do
  # controlrepo is a helper tool to setup spec and integration testing inside of a
  # Puppet control repository.  We're not using the rake rakes, but instead
  # directly invoking `rspec spec` in an effort to cut down on the amount of
  # implicit, magic behavior.  The controlrepo gem provides value in the form of
  # an updated set of depenencies suitable for spec testing using rspec-puppet.
  #
  # https://github.com/jeffmccune/controlrepo_gem
  gem 'controlrepo'
  # Interactive debugger and REPL breakpoint tool
  # See http://pryrepl.org/
  gem 'pry'
  gem 'pry-stack_explorer'
end

group :test, :development do
  gem 'puppet', '4.9.4'
  # should be 3.7.2 but not available on rubygems
  gem 'facter'
  gem 'hiera', '3.3.1'
  gem 'hiera-eyaml', '2.1.0'
  gem 'parallel_tests'

  # other testing gems we want
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'rake-notes'

  # pinning specific versions
  gem 'puppet-lint', '~> 2.1'

end

