require_relative "lib/pg-searchable/version"

Gem::Specification.new do |gem|
  gem.authors = ["wyozi"]
  gem.name = "pg-searchable"
  gem.summary = "Simple full-text searching for Rails"

  gem.files = `git ls-files | grep -Ev '^(test|myapp|examples)'`.split("\n")
  gem.version = PgSearchable::VERSION
  gem.required_ruby_version = ">= 2.5.0"
end
