class Subject < ActiveRecord::Base
 
  has_many :pages
  
  validates_presence_of :name
  # Have ID and foreign keys but we don't need to validate those
  # same thing with timestamps?
  # Boolean doesn't need to be validated
  # position could make sure it's a number but we're coupling this to the select ioptions
  # In most cases, don't validate ids, fks, timestamps, booleans, counters
  
  # but what if name is too long
  validates_length_of :name, :maximum => 255
  # we already have validates_presence_of, and it checks for nothing but whitespace

  # attr_accessible :title, :body
  attr_accessible :name, :visible, :position

  scope :visible, where(:visible => true)
  scope :invisible, where(:visible => false)
  scope :search, lambda {|query| where(["name LIKE ?", "%#{query}%"])}
end
