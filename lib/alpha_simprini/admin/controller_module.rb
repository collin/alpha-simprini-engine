module AlphaSimprini::Admin::ControllerModule
  extend ActiveSupport::Concern

  module ClassMethods
    def before_filter(*args)
      base_controller.before_filter(*args)
    end

    def base_controller(superclass=ApplicationController)
      @base_controller ||= const_set(:BaseController, Class.new(superclass))
    end
  end
end