# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Categoria.create([{nome: 'Avx Home'}, {descricao: 'Ebooks do AVX Home'}, {ativo: true},
                  {url: 'http://avxhome.in/ebooks'}, {path: 'avxhome'}])

Host.create([{imagem_padrao: 'http://www.solutionhacks.eu/wp-content/uploads/2015/03/nitroflare-premium-account.png'},
             {titulo: 'Nitro Flare'}, {ativo: true}, {url: 'http://nitroflare.com'}])
Host.create([{imagem_padrao: 'https://plusinstant.com/image/cache/data/logo/filejoker-400x400.png'},
            {titulo: 'File Joker'}, {ativo: true}, {url: 'http://filejoker.net'}])
Host.create([{imagem_padrao: 'https://www.hipercontas.com.br/images/rockfile/logo.gif'},
            {titulo: 'Rock File'}, {ativo: true}, {url: 'http://rockfile.eu'}])