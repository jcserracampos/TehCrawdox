class Host < ActiveRecord::Base
  has_many :links

  validates_uniqueness_of :url
end
