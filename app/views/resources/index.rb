 # coding: utf-8
class Views::Resources::Index < Views::Resources::Base
  include Views::Listing
  include AlphaSimprini::Admin::ActionItems
  
  def page_header
    h3 title_text
  end
  
  def blank_slate
    return if collection.any?
    h1 do
      text "No #{resource_name.pluralize.titlecase} found"
      if scopes.any?
        scope = scopes.detect{|scope| scope.matches(params[:scope])}
        text " in scope '#{scope.display_name}'."
      else
        text "."
      end

    end
    if params[:search]
      h2 do
        text "Maybe the search term: '#{params[:search]}' is too restrictive."
      end
    end
    h3 do
      text "Try changing your scope and search options."
    end
  end
  
  def body_content
    # page_header
    section class:'container-fluid' do    
      display_filters
      section class:listing_class do
        back_link
        listing
      end
    end
  end

  def title_text
    "#{resource_name} Index"
  end

  def listing_class
    [:listing, any_filters? ? :filtered : :unfiltered]
  end

  delegate :scopes, :sortings, :search_fields, :filters, :date_filters, 
    to: 'component'

  def display_filters
    return unless any_filters?
    section class:'filters' do    
      section { search }
      section { scope_selector }
      section { sort_selector }
      section { filter_selector }
      date_filter_selector
    end
  end

  def any_filters?
    [scopes, sortings, search_fields, filters, date_filters].flatten.any?
  end

  def filter_param_names
    (filters + date_filters).map(&:param_name)
  end

  def date_filter_selector
    return if date_filters.none?
    date_filters.each do |filter|
      fieldset do     
        form_for filter.active_model(params[filter.param_name]), as: filter.param_name, method: 'get', url:request.path do |f|
          h3 "#{filter.display_name} Between"

          params.slice(:scope, :sort, :direction, :search, *(filter_param_names - [filter.param_name])).each do |key, value|
            next if key =~ /^date_filter_/
            text raw hidden_field_tag(key, value)
          end

          section do
            f.date_select :from, order: [:month, :year], include_blank: true            
          end
          section do          
            f.date_select :until, order: [:month, :year], include_blank: true
          end
          button "Clear", class:"btn reset"
          f.submit "Filter Date", class:"btn btn-primary"
        end
      end
    end
  end

  def filter_selector
    return if filters.none?
    filters.each do |filter|    
      h3 "Filter #{filter.display_name}"
      select class:'auto-filter', name:filter.param_name do
        if filter.include_blank?
          option "Unfiltered",
            'data-href' => collection_path(params.slice(:scope, :direction, :search, *(filter_param_names - [filter.param_name])))
        end

        filter.options_for_select.each do |content, value|
          option content, 
            value:value, 
            selected:value == params[filter.param_name],
            'data-href' => collection_path(params.slice(:scope, :direction, :search, *filter_param_names).merge(filter.param_name => value))
        end
      end
    end
  end

  def search
    return if search_fields.none?
    h3 "Search"
    form action:request.fullpath do
      input type:'search', name:'search', value:params[:search], placeholder: search_fields.map(&:to_s).map(&:titlecase).to_sentence
      params[:scope] and input type:'hidden', name:'scope', value:params[:scope]
      params[:sort] and input type:'hidden', name:'sort', value:params[:sort]
      params[:direction] and input type:'hidden', name:'direction', value:params[:direction]
    end      
  end

  def scope_selector
    return if scopes.none?
    h3 "Scope"
    nav class:'scopes' do
      scopes.each_with_index do |scope, index|
        scope_class = "scope"
        scope_class += " current" if scope.matches(params[:scope])

        link_to collection_path(scope.path_options.reverse_merge(params.slice(:sort, :direction, :search, *filter_param_names))), class: scope_class do
          span scope.display_name#, class:"lead"
          text " "
          span scope.count(controller.send(:end_of_association_chain)), class:"count"
        end
      end
    end
  end

  def sort_selector
    return if sortings.none?
    h3 "Sort"
    nav class:'sortings' do
      sortings.each_with_index do |sorting, index|
        sorting_class = "sorting"
        sorting_class += " current" if sorting.matches(params[:sort])

        link_to collection_path(sorting.path_options.reverse_merge(params.slice(:scope, :direction, :search, *filter_param_names))), class: sorting_class do
          span sorting.display_name#, class:"lead"
        end
      end
    end

    h3 "Sort Direction"
    nav class:'sort-directions' do
      descending_path = url_for({only_path:true}.reverse_merge(params).except('direction'))
      ascending_path = url_for({direction:'asc', only_path:true}.reverse_merge(params))
      link_to "Descending ▼", descending_path, class:"sort-direction #{:current if params[:direction].nil?}"
      link_to "Ascending ▲", ascending_path, class:"sort-direction #{:current if params[:direction] == 'asc'}"
    end
  end
end