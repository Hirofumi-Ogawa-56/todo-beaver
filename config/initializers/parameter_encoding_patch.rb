# config/initializers/parameter_encoding_patch.rb
Rails.application.config.to_prepare do
  ActionController::Base.class_eval do
    if instance_variable_get(:@_parameter_encodings).nil?
      instance_variable_set(:@_parameter_encodings, {})
    end
  end
end
