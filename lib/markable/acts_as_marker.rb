module Markable
  module ActsAsMarker
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_marker(options = {})
        Markable.set_models
        class_eval do
          class << self
            attr_accessor :marker_name
          end
        end
        self.marker_name = self.name.downcase.to_sym

        class_eval do
          has_many :marker_marks, :class_name => 'Markable::Mark', :as => :marker, :dependent => :delete_all
          include Markable::ActsAsMarker::MarkerInstanceMethods
        end
        Markable.add_marker self
      end
    end

    module MarkerInstanceMethods
      def method_missing(method_sym, *args)
        Markable.models.each do |model_name|
          if method_sym.to_s =~ Regexp.new("^[\\w_]+_#{model_name.underscore.pluralize}$") ||
              method_sym.to_s =~ Regexp.new("^#{model_name.underscore.pluralize}_marked_as(_[\\w_]+)?$")
            model_name.constantize # ping model
            if self.methods.include? method_sym # method has appear
              return self.method(method_sym).call(*args) # call this method
            end
          end
        end
        super
      rescue
        super
      end

      def set_mark(mark, markables)
        Array.wrap(markables).each do |markable|
          Markable.can_mark_or_raise? self, markable, mark
          markable.mark_as mark, self
        end
      end

      def remove_mark(mark, markables)
        Markable.can_mark_or_raise? self, markables, mark
        Array.wrap(markables).each do |markable|
          markable.unmark mark, :by => self
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Markable::ActsAsMarker
