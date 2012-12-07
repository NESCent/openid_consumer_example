class Page < ActiveRecord::Base
  
  belongs_to :subject
  has_many :sections
   # this is not rails convention
  has_and_belongs_to_many :editors, :class_name => "AdminUser"
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 255

  validates_presence_of :permalink
  validates_length_of :permalink, :within => 3..255
  validates_uniqueness_of :permalink
  # Can scope this within another bound column, e.g. :scope => :subject_id
  

  # don't need this anymore  
  # attr_accessible :name, :permalink, :position
end
