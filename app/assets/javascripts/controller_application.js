angular.module('tehparadox', [])
    .controller('ControllerPrincipal', function ($scope, $route, $routeParams, $location) {

        //$scope.$route = $route;
        //$scope.$location = $location;
        //$scope.$routeParams = $routeParams;

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
            // Varre os links a procura da url da publicação e o remove
            for (j = 0; j < $scope.publicacoes[i].links.length; j++) {
                if ($scope.publicacoes[i].links[j].search("tehparadox") != null) {
                    $scope.publicacoes[i].links.slice(j, 1)
                }
            }

            $scope.publicacoes[i].hosts = [];

            // Agrupar os links por host
            for (w = 0; w < $scope.publicacoes[i].links.length; w++) {
                if ($scope.publicacoes[i].hosts.indexOf($scope.publicacoes[i].links[w].match(/(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+[\w.,@?^=%&amp;:\/~+#-]/g)) === -1) {
                    if ($scope.publicacoes[i].links[w].match('http://tehparadox.com/')) {
                    } else {
                        $scope.publicacoes[i].hosts.push($scope.publicacoes[i].links[w].match(/(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+[\w.,@?^=%&amp;:\/~+#-]/g));
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


    });
//.config(function ($routeProvider, $locationProvider) {
//    $routeProvider
//        .when('/Publicacoes', {
//            templateUrl: 'publicacoes/index.html',
//            controller: 'ControllerPublicacoes',
//            resolve: {
//                // Para causar um delay
//                //delay: function($q, $timeout) {
//                //    var delay = $q.defer();
//                //    $timeout(delay.resolve, 1000);
//                //    return delay.promise;
//            }
//        })
//        .when('Publicacoes/:publicacaoId', {
//            templateUrl: 'publicacoes/show.html',
//            controller: 'ControllerPublicacoes'
//        });
//    $locationProvider.html5Mode(true);
//});