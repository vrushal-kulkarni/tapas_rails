class CommunitiesController < CatalogController
  include ApiAccessible
  self.copy_blacklight_config_from(CatalogController)

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress"
    pretty_json(202) and return
  end

  #This method displays all the communities/projects created in the database
  def index
    @page_title = "All Projects"
    self.search_params_logic += [:communities_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    render 'shared/index'
  end

  #This method is the helper method for index. It basically gets the communities
  # using solr queries
  def communities_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:Community"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  #This method is used to display various attributes of community
  def show
    @community = Community.find(params[:id])
  end

  #This method is used to create a new community/project
  def new
    @page_title = "Create New Community"
    @community = Community.new
  end

  #This method contains the actual logic for creating a new community
  def create
    @community = Community.new(params[:community])
    @community.did = @community.pid
    @community.save!
    redirect_to @community and return
  end

  #This method is used to edit a particular community
  def edit
     @community = Community.find(params[:id])
     @page_title = "Edit #{@community.title}"
  end

  #This method contains the actual logic for editing a particular community
  def update
    # @community = Community.find(params[:id])
    @community = Community.find_by_did(params[:id])
    @community.update_attributes(params[:community])
    @community.save!
    redirect_to @community and return
  end
end
