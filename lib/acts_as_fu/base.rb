RAILS_ROOT = File.join(File.dirname(__FILE__), '..') unless defined?(Rails.root)
RAILS_ENV  = 'test' unless defined?(Rails.env)
if defined?(JRuby)
  require 'activerecord-jdbcsqlite3-adapter'
else
  require 'sqlite3'
end

module ActsAsFu
  module Base
    def build_model(name, options = {}, &block)
      connect! unless connected?

      klass_name  = name.to_s.classify
      super_class = options[:superclass] || ActsAsFu::Connection
      contained   = options[:contained] || Object

      begin
        old_klass = contained.const_get(klass_name)
        old_klass.reset_column_information if old_klass.respond_to?(:reset_column_information)
      rescue
      end

      contained.send(:remove_const, klass_name) rescue nil
      klass = Class.new(super_class)
      contained.const_set(klass_name, klass)

      # table_name isn't available until after the class is created.
      if super_class == ActsAsFu::Connection
        ActsAsFu::Connection.connection.create_table(klass.table_name, force: true) {}
      end

      model_eval(klass, &block)
      klass
    end

    private

    def connect!
      adapter = if defined?(JRuby)
                  'jdbcsqlite3'
                else
                  'sqlite3'
                end
      ActsAsFu::Connection.connect!(
                                      adapter: adapter,
                                      database: ':memory:'
                                    )
      ActsAsFu::Connection.connected = true
    end

    def connected?
      ActsAsFu::Connection.connected
    end

    def model_eval(klass, &block)
      class << klass
        def method_missing_with_columns(sym, *args, &_block)
          ActsAsFu::Connection.connection.change_table(table_name) do |t|
            t.send(sym, *args)
          end
        end

        alias_method_chain :method_missing, :columns
      end

      klass.class_eval(&block) if block_given?

      class << klass
        remove_method :method_missing
        alias_method :method_missing, :method_missing_without_columns
      end
    end
  end
end
