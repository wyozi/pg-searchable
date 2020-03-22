# frozen_string_literal: true

require 'active_support/concern'

module PgSearchable
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def searchable_column(column_name)
        name = "search_#{column_name.to_s}"
        define_singleton_method(name) do |*args|
          Searcher.new(self).exec(column_name, *args)
        end
      end
    end

    class Searcher
      DISALLOWED_TSQUERY_CHARACTERS = /['?\\:‘’]/.freeze

      def initialize(model)
        @model = model
      end

      def exec(column_name, query, raw:false, prefix:false, websearch:false)
        column_ref = "#{@model.quoted_table_name}.#{column_name}"
  
        vector = Arel::Nodes::NamedFunction.new(
          "to_tsvector",
          [dictionary, Arel.sql(column_ref)]
        )

        opts = {
          prefix: prefix,
          raw: raw,
          websearch: websearch
        }
  
        query = tsquery(query, opts)
  
        condition = Arel::Nodes::Grouping.new(
          Arel::Nodes::InfixOperation.new("@@", vector, query)
        )
  
        condition
      end
      
      private

      def dictionary
        Arel::Nodes.build_quoted(:simple)
      end

      def normalize(x)
        x # TODO
      end

      def tsquery(query, opts)
        query_terms = query.split(" ").compact
        tsq =
          if query.blank?
            Arel::Nodes.build_quoted("")
          elsif opts[:raw] || opts[:websearch]
            Arel::Nodes.build_quoted(query)
          else
            tsquery_for_terms(query_terms, prefix: opts[:prefix])
          end
  
        fn_name = opts[:websearch] ? "websearch_to_tsquery" : "to_tsquery"
        Arel::Nodes::NamedFunction.new(fn_name, [dictionary, tsq])
      end
  
      def tsquery_for_terms(terms, prefix:)
        terms = terms.map { |term| tsquery_term(term, prefix: prefix) }
        terms.inject do |memo, term|
          term_anded = Arel::Nodes::InfixOperation.new("||", Arel::Nodes.build_quoted(" & "), term)
          Arel::Nodes::InfixOperation.new("||", memo, term_anded)
        end
      end
  
      def tsquery_term(unsanitized_term, prefix:)
        negated = false
  
        if unsanitized_term.start_with?("!")
          unsanitized_term[0] = ''
          negated = true
        end
  
        sanitized_term = unsanitized_term.gsub(DISALLOWED_TSQUERY_CHARACTERS, " ")
        tsquery_expression(sanitized_term, negated: negated, prefix: prefix)
      end
  
      # After this, the SQL expression evaluates to a string containing the term surrounded by single-quotes.
      # If :prefix is true, then the term will have :* appended to the end.
      # If :negated is true, then the term will have ! prepended to the front.
      def tsquery_expression(term, negated:, prefix:)
        terms = [
          (Arel::Nodes.build_quoted('!') if negated),
          Arel::Nodes.build_quoted("' "),
          Arel::Nodes.build_quoted(term),
          Arel::Nodes.build_quoted(" '"),
          (Arel::Nodes.build_quoted(":*") if prefix)
        ].compact
  
        terms.inject do |memo, term|
          Arel::Nodes::InfixOperation.new("||", memo, Arel::Nodes.build_quoted(term))
        end
      end
    end
  end
end