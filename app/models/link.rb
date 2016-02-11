class Link < ActiveRecord::Base
  belongs_to :publicacao
  belongs_to :host
end
