module AlphaSimprini::Admin::ActionItems
  extend ActiveSupport::Concern
  included do
    class_attribute :action_items
    self.action_items = []
  end

  module ClassMethods
    def action_item(name, action=nil, options={}, &block)
      self.action_items << [name, action, options, block]
    end

    def inherited(subclass)
      super
      subclass.action_items = []
    end
  end
end