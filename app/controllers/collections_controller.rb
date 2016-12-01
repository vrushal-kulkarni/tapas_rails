class CollectionsController < CatalogController
  # include ApiAccessible

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Collection upsert accepted"
    pretty_json(202) and return
  end

  def index
    @page_title = "All Collections"
    self.search_params_logic += [:collections_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    render 'shared/index'
  end

  # def show #inherited from catalog controller
  # end

  def collections_filter(solr_parameters, user_parameters)
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Collection"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  def new
    @page_title = "Create New Collection"
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Community"
    # results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi')
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi', rows: count)

    @arr =[]
    results.each do |res|
      # @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      if !res['title_info_title_ssi'].blank? && !res['did_ssim'].blank? && res['did_ssim'].count > 0
        @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      end 
    end
    @collection = Collection.new
  end

  def create
    # @collection = Collection.new
    community = Community.find("#{params[:collection][:community]}")
    params[:collection].delete("community")
    @collection = Collection.new(params[:collection])
    @collection.did = @collection.pid
    @collection.depositor = "000000000"
    # @collection.title = params[:collection][:title]
    # @collection.community = Community.find("#{params[:collection][:community]}")
    @collection.save!
    @collection.community = community
    @collection.save!
    redirect_to @collection and return
  end

  def edit
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Community"
    # results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi')
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi', rows: count)
    @arr =[]
    results.each do |res|
      if !res['title_info_title_ssi'].blank? && !res['did_ssim'].blank? && res['did_ssim'].count > 0
        @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      end
    end
    @collection = Collection.find(params[:id])
    @page_title = "Edit #{@collection.title}"
  end

  def update
    community = Community.find("#{params[:collection][:community]}")
    params[:collection].delete("community")
    @collection = Collection.find(params[:id])
    # @core_files = CoreFile.find_by_did(params[:id])
    @collection.update_attributes(params[:collection])
    @collection.save!
    @collection.community = community
    @collection.save!
    redirect_to @collection and return
  end
end
