angular.module('tehparadox', [])
    .controller('ControllerPrincipal', function ($scope) {


    })
    .controller('ControllerPublicacoes', function ($scope) {
        $scope.publicacoes = Publicacoes;

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