class Link < ActiveRecord::Base
  belongs_to :publicacao
  belongs_to :host

  validates_uniqueness_of :link
end
