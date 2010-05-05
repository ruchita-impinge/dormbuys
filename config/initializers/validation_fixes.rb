# get the actual associated model error messages
# not xyz is invalid
module ValidatesAssociatedAttributes
  module ActiveRecord::Validations::ClassMethods
    def validates_associated(*associations)
      class_eval do
        validates_each(associations) do |record, associate_name, value|
          (value.respond_to?(:each) ? value : [value]).each do |rec|
            if rec && !rec.valid?
              rec.errors.each do |key, value|
                record.errors.add(key, value)
              end
            end
          end
        end
      end
    end
  end
end

# make the associated model error messages unique
# so you don't see the same error message more than once
class ActiveRecord::Errors
  alias old_full_messages full_messages
  def full_messages
    old_full_messages.uniq
  end
end
