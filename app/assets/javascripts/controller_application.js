angular.module('tehparadox', [])
    .controller('ControllerPrincipal', function ($scope) {


    })
    .controller('ControllerPublicacoes', function ($scope) {
        $scope.publicacoes = Publicacoes;

        //$scope.url = urlUpdate;


        // Retorna o id da Imagem da Publicação
        //$scope.idImagem = function (publicacao) {
        //    for (i = 0; $scope.imagens.length > i; i++) {
        //        if ($scope.imagens[i].publicacao_id === publicacao.id) {
        //            return i;
        //            break;
        //        }
        //    }
        //};
        //
        //
        //for (k = 0; $scope.publicacoes.length > k; k++) {
        //    $scope.publicacoes[k].links = [];
        //
        //    for (j = 0; $scope.links.length > j; j++) {
        //        if ($scope.links[j].publicacao_id === $scope.publicacoes[k].id) {
        //            $scope.publicacoes[k].links.push($scope.links[j])
        //        }
        //    }
        //}


        // Gerar o dlc por ajax ou javascript
        $scope.gerarDlc = function (publicacao, host) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/confirmar?host=").concat(host);
            window.location.href = $scope.url;

            $scope.publicacoes(publicacao.id).hide = true;
        };

        $scope.confirmarSemHost = function (publicacao) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/confirmar_sem_host");
            window.location.href = $scope.url;
        };

        $scope.ignorar = function (publicacao) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/ignorar");
            window.location.href = $scope.url;
        };

        $scope.rejeitar = function (publicacao) {
            $scope.url = window.location.host;
            $scope.url = "http://".concat($scope.url).concat("/publicacoes/").concat(publicacao.id).concat("/rejeitar");
            window.location.href = $scope.url;
        };


    });