module AjaxDatatablesRails
  module Datatable
    class Datatable

      def initialize(datatable)
        @datatable = datatable
        @options   = datatable.params
        puts "options: \n"
        @options.each { |k,v| puts"#{k}:\t #{v}\n" }
      end

      def polymorphic?(column_options)
        symbolized_column = column_options.with_indifferent_access[:data].to_sym
        column_view = @datatable.view_columns.dig(symbolized_column)
        return true if column_view && column_view[:sources].present?

        false
      end

      def columns
        @columns ||= get_param(:columns).map do |index, column_options|
           polymorphic?(column_options) ? PolymorphicColumn.new(@datatable, index, column_options) : Column.new(@datatable, index, column_options)
        end
      end
    end

    class PolymorphicColumn < AjaxDatatablesRails::Datatable::Column

      attr_reader :datatable, :index, :options
      attr_writer :search

      def initialize(datatable, index, options)
        @datatable   = datatable
        @index       = index
        @options     = options
        @view_column = datatable.view_columns[options[:data].to_sym].with_indifferent_access
      end

      def data
        options[:data].presence || options[:name]
      end

      def sources
        puts "@view_column: #{@view_column}"
        @view_column[:sources]
      end

      def tables
        puts "tables: #{models}"
        @tables ||= models.collect { |model| model.respond_to?(:arel_table) ? model.arel_table : model }
      end

      def models
        @models ||= sources.keys.collect { |item| item.constantize }
      end

      def fields
        @fields ||= sources.values.collect { |item| item.to_sym }
      end

      def custom_field?
        true
      end

      # Add formatter option to allow modification of the value
      # before passing it to the database
      def formatter
        @view_column[:formatter]
      end

      def formatted_value
        formatter ? formatter.call(search.value) : search.value
      end

      def searchable?
        @view_column.fetch(:searchable, false)
      end

      def cond
        @view_column.fetch(:cond, :like)
      end

      def search
        @search ||= SimpleSearch.new(options[:search])
      end

      def searched?
        search.value.present?
      end

      def non_regex_search
        case cond
        when Proc
          filter
        when :null_value
          null_value_search
        when :start_with
          casted_column.matches("#{formatted_value}%")
        when :end_with
          casted_column.matches("%#{formatted_value}")
        when :like
          casted_column.matches("%#{formatted_value}%")
        when :string_eq
          raw_search(:eq)
        when :string_in
          raw_search(:in)
        end
      end

      def search_query
        return unless sources

        query = sources.collect do |table, field|
          @table = table.constantize.arel_table
          @field = field.to_sym
          non_regex_search
        end
        query.reduce(:or)
      end

      def orderable?
        @view_column.fetch(:orderable, false)
      end

      def orders
        @orders ||= get_param(:order).map do |_, order_options|
          SimpleOrder.new(self, order_options)
        end
      end

      def sort_query
        return '' unless sources

        query = 'COALESCE('
        sources.collect do |table, field|
          table_name = table.constantize.arel_table.name
          query += "#{table_name}.#{field}, "
        end
        query = query[0...-2] + ')'
        query
      end

      private

      def type_cast
        @type_cast ||= DB_ADAPTER_TYPE_CAST.fetch(datatable.db_adapter, TYPE_CAST_DEFAULT)
      end

      def casted_column
        @casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [@table[@field].as(type_cast)])
      end
    end
  end
end
