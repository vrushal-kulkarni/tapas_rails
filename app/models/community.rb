class Community < CerberusCore::BaseModels::Community
  include Did
  include OGReference
  include DrupalAccess
  include TapasQueries
  include InlineThumbnail
  include StatusTracking
  include TapasRails::MetadataAssignment

  before_save :ensure_unique_did
  before_save :match_dc_to_mods

  has_collection_types ["Collection"]
  has_community_types  ["Community"]

  parent_community_relationship :community

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  has_attributes :project_members, datastream: "properties", multiple: true
  has_attributes :title, datastream: "DC"
  has_attributes :description, datastream: "DC"

  # Look up or create the root community of the graph
  def self.root_community
    if Community.exists?(Rails.configuration.tap_root)
      Community.find(Rails.configuration.tap_root)
    else
      community = Community.new(:pid => Rails.configuration.tap_root)
      community.depositor = "000000000"
      community.mods.title = "TAPAS root"
      community.mass_permissions = "private"
      community.save!
      return community
    end
  end

  def as_json
    fname = (thumbnail_1.label == 'File Datastream' ? '' : thumbnail_1.label)
    { :members => project_members,
      :depositor => depositor,
      :access => drupal_access,
      :thumbnail => fname,
      :title => mods.title.first,
      :description => mods.abstract.first
    }
  end

  def match_dc_to_mods
    # self.DC.title = self.mods.title.first
    # self.DC.description = self.mods.abstract.first if !self.mods.abstract.blank?
    self.mods.title = self.DC.title.first
    self.mods.abstract = self.DC.description.first
  end
end
