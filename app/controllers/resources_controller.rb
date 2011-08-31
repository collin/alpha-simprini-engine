class ResourcesController < ApplicationController
  inherit_resources
  def resource_name
    resource_class.name
  end
  helper_method :resource_name
end