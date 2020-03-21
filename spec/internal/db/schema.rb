# frozen_string_literal: true

ActiveRecord::Schema.define do
  # Set up any tables you need to exist for your test suite that don't belong
  # in migrations.

  create_table "products" do |t|
    t.string "name"
    t.string "description"
  end

  add_index "products", "to_tsvector('simple'::regconfig, COALESCE((description)::text, ''::text))", name: "index_products_on_description", using: :gin
end
