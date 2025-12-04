# Este é um fluxo de trabalho básico para ajudar você a começar com ações



nome : CI



# Controla quando o fluxo de trabalho será executado

sobre :

 # Aciona o fluxo de trabalho em eventos de solicitação push ou pull, mas apenas para o branch "principal"

 empurrar :

   ramos : [ "principal" ]

 solicitação de pull :

   ramos : [ "principal" ]



 # Permite que você execute este fluxo de trabalho manualmente na guia Ações

 fluxo de trabalho_despacho :



# Uma execução de fluxo de trabalho é composta de um ou mais trabalhos que podem ser executados sequencialmente ou em paralelo

empregos :

 # Este fluxo de trabalho contém um único trabalho chamado "build"

 construir :

   # O tipo de executor no qual o trabalho será executado

   executa em : ubuntu-latest



   # As etapas representam uma sequência de tarefas que serão executadas como parte do trabalho

   passos :

     # Faz check-out do seu repositório em $GITHUB_WORKSPACE, para que seu trabalho possa acessá-lo

     - usos : ações/checkout@v3



     # Executa um único comando usando o shell do runner

     - nome : Executa um script de uma linha

       executar : eco Olá, mundo!



     # Executa um conjunto de comandos usando o shell do runner

     - nome : Executa um script multi-linha

       correr : |

         echo Adicionar outras ações para construir,

         teste de eco e implante seu projeto.
