require_relative "lib/pg-searchable/version"

Gem::Specification.new do |gem|
  gem.authors = ["wyozi"]
  gem.name = "pg-searchable"
  gem.summary = "Simple full-text searching for Rails"
  gem.homepage = "https://github.com/wyozi/pg-searchable"
  gem.licenses = ["MIT"]

  gem.files = `git ls-files | grep -Ev '^(spec)'`.split("\n")
  gem.version = PgSearchable::VERSION
  gem.required_ruby_version = ">= 2.5.0"
end
