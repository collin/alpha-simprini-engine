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
    link_to "Create a #{resource_name}", new_resource_path, class: 'new' unless no_actions
  end
  
  def body_content
    # page_header
    section class:'navbar-outer' do    
      section class:'navbar-inner' do
        search
        section class:'btn-toolbar' do
          scope_selector
          sort_selector
          filter_selector
        end
      end
    end

    listing
  end

  delegate :scopes, :sortings, :search_fields, :filters, to: 'component'

  def filter_param_names
    filters.map(&:param_name)
  end

  def filter_selector
    return if filters.none?
    filters.each do |filter|    
      select class:'auto-filter', name:filter.param_name do
        if filter.include_blank?
          option "Unfiltered",
            'data-href' => collection_path(params.slice(:scope, :direction, *(filter_param_names - [filter.param_name])))
        end

        filter.options_for_select.each do |content, value|
          option content, 
            value:value, 
            selected:value == params[filter.param_name],
            'data-href' => collection_path(params.slice(:scope, :direction, *filter_param_names).merge(filter.param_name => value))
        end
      end
    end
  end

  def search
    return if search_fields.none?
    form class:'navbar-search', action:request.fullpath do
      input type:'search', class:'search-query', name:'search', value:params[:search]
      params[:scope] and input type:'hidden', name:'scope', value:params[:scope]
      params[:sort] and input type:'hidden', name:'sort', value:params[:sort]
      params[:direction] and input type:'hidden', name:'direction', value:params[:direction]
    end      
  end

  def scope_selector
    return if scopes.none?
    nav class:'scopes' do
      scopes.each_with_index do |scope, index|
        scope_class = "scope"
        scope_class += " current" if scope.matches(params[:scope])

        link_to collection_path(scope.path_options.reverse_merge(params.slice(:sort, :direction, *filter_param_names))), class: scope_class do
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

        link_to collection_path(sorting.path_options.reverse_merge(params.slice(:scope, :direction, *filter_param_names))), class: sorting_class do
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