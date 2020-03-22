## pg-searchable

pg-searchable is a quick way to make Postgres columns full-text searchable in Rails models, with support for composing complex OR/AND queries.

If all you need is a straightforward search with trigram/multi-column support, [pg_search](https://github.com/Casecommons/pg_search) is probably a better fit.

### Install

`gem "pg-searchable"`

### Setup

```ruby
class Product < ActiveRecord::Base
  include PgSearchable::Model
  searchable_column :name
end
```

### Usage

```ruby
# Add test data
sour_bread = Product.create!(name: "Sour bread")
italian_pasta = Product.create!(name: "Italian pasta")
rye_bread = Product.create!(name: "Rye bread")
sushi = Product.create!(name: "Sour Sushi Itamae")

# Basic usage
bread_condition = Product.search_name("bread")
expect(Product.where(bread_condition)).to match_array [sour_bread, rye_bread]

ita_condition = Product.search_name("ita", prefix: true)
expect(Product.where(ita_condition)).to match_array [italian_pasta, sushi]

nonsour_condition = Product.search_name("!sour")
expect(Product.where(nonsour_condition)).to match_array [italian_pasta, rye_bread]

# Use Postgres built-in websearch
ws_condition = Product.search_name("sushi or pasta", websearch: true)
expect(Product.where(ws_condition)).to match_array [sushi, italian_pasta]

# Composing basic searches
non_sour_breads = Product.where(bread_condition.and(nonsour_condition))
expect(non_sour_breads).to match_array [rye_bread]

nonsour_or_ita = Product.where(nonsour_condition.or(ita_condition))
expect(nonsour_or_ita).to match_array [rye_bread, italian_pasta, sushi]

# Advanced options
raw_condition = Product.search_name("sushi | pasta", raw: true)
expect(Product.where(raw_condition)).to match_array [sushi, italian_pasta]
```

### Usage: Scopes

pg-searchable merely builds conditions, not chainable `.where` scopes.
However, adding a scope for your condition can be done with one line if needed:
```ruby
class Product < ActiveRecord::Base
  include PgSearchable::Model
  searchable_column :name
  scope :by_name, -> (name) { where(search_name(name)) }
end

prods = Product.by_name("bread")
expect(prods.count).to be(2)
```

### Development

**Tests**

Main tests for the library actually exist in the README itself.
A test case scans the readme for ruby blocks and runs the code in them as a unit test.

**Running tests locally:**

1. Start local Postgres: `bin/local-docker-testing`
2. Run tests: `bundle exec rspec`

### Credits

pg_search provided much of the inspiration and basis