angular.module('tehparadox', [])
    .controller('ControllerPrincipal', function ($scope) {



    })
    .controller('ControllerPublicacoes', function ($scope) {
        $scope.publicacoes = Publicacoes;
        //$scope.url = urlUpdate;

        for (i = 0; i < $scope.publicacoes.length; i++) {
            // Captura de todos os links disponíveis na publicação
            $scope.publicacoes[i].links = $scope.publicacoes[i].descricao
                .match(/(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?/g);
            //Retira as tags HTML da descrição da publicação
            //E retira qualquer texto posterior à tag Code
            $scope.publicacoes[i].descricao = $scope.publicacoes[i].descricao.replace(/<[^>]*>/g, "").split("Code")[0];
            // Define a url da imagem baseado nos links capturados
            $scope.publicacoes[i].linkImagemExterna = $scope.publicacoes[i].links[0];
            // Remove o endereço da publicação e da imagem
            $scope.publicacoes[i].links = $scope.publicacoes[i].links.slice(2, $scope.publicacoes[i].links.length);
            for (j = 0; j < $scope.publicacoes[i].links.length; j++) {
            }

            $scope.publicacoes[i].hosts = [];

            // Agrupar os links por host
            for (j = 0; j < $scope.publicacoes[i].links.length; j++) {
                // Varre os links a procura da url da publicação e o remove
                if ($scope.publicacoes[i].links[j].search("tehparadox") != null) {
                    $scope.publicacoes[i].links.slice(j, 1)
                }

                var host = $scope.publicacoes[i].links[j].match(/(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+[\w.,@?^=%&amp;:\/~+#-]/g);


                if ($scope.publicacoes[i].hosts.indexOf(host.to_s) < 0) {
                    if ($scope.publicacoes[i].links[j].match('http://tehparadox.com/')) {
                    } else {
                        $scope.publicacoes[i].hosts.push(host);
                    }
                }


            }
        }

        // Gerar o dlc por ajax ou javascript
        $scope.gerarDlc = function(publicacao, host) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/confirmar?host=").concat(host);
            window.location.href = $scope.url;

            $scope.publicacoes(publicacao.id).hide = true;
        };

        $scope.confirmarSemHost = function(publicacao) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/confirmar_sem_host");
            window.location.href = $scope.url;
        };

        $scope.ignorar = function(publicacao) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/ignorar");
            window.location.href = $scope.url;
        };

        $scope.rejeitar = function(publicacao) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/rejeitar");
            window.location.href = $scope.url;
        };


    });