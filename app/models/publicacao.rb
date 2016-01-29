class Publicacao < ActiveRecord::Base
  belongs_to :categoria

  CRIADA = 0
  NOVA = 1
  CONFIRMADA = 2
  IGNORADA = 3
  REJEITADA = 4
  GERADA = 5
  BAIXADA = 6

  %w(nova confirmada ignorada rejeitada gerada baixada).each do |state|
    define_method "#{state}?" do
      situacao == self.class.const_get(state.upcase)
    end
  end
end
