 # coding: utf-8
class Views::Resources::Index < Views::Resources::Base
  include Views::Listing

  def self.action_items
    @action_items ||= []
  end
  
  def page_header
    h1 "#{resource_name} Index"
  end
  
  def blank_slate
    link_to "Create a #{resource_name}", new_resource_path, class: 'new'
  end
  
  def body_content
    # page_header
    section class:'btn-toolbar' do
      scope_selector
      sort_selector      
    end
    listing
  end

  delegate :scopes, :sortings, to: 'component'

  def scope_selector
    return if scopes.none?
    nav class:'scopes' do
      scopes.each_with_index do |scope, index|
        scope_class = "scope"
        scope_class += " current" if scope.matches(params[:scope])

        link_to collection_path(scope.path_options.reverse_merge(params.slice(:sort, :direction))), class: scope_class do
          span scope.display_name#, class:"lead"
          text " "
          span scope.count(collection.unscoped), class:"count"
        end
      end
    end
  end

  def sort_selector
    return if sortings.none?
    nav class:'sortings' do
      sortings.each_with_index do |sorting, index|
        sorting_class = "sorting"
        sorting_class += " current" if sorting.matches(params[:sort])

        link_to collection_path(sorting.path_options.reverse_merge(params.slice(:scope, :direction))), class: sorting_class do
          span sorting.display_name#, class:"lead"
        end
      end
    end

    nav class:'sort-directions' do
      descending_path = url_for({only_path:true}.reverse_merge(params).except('direction'))
      ascending_path = url_for({direction:'asc', only_path:true}.reverse_merge(params))
      link_to "Descending ▼", descending_path, class:"sort-direction #{:current if params[:direction].nil?}"
      link_to "Ascending ▲", ascending_path, class:"sort-direction #{:current if params[:direction] == 'asc'}"
    end
  end
end