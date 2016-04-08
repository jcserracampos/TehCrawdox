class Categoria < ActiveRecord::Base
  has_many :publicacaos

  validates_uniqueness_of :nome
end
