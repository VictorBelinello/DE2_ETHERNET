# Geral
O projeto foi desenvolvido e testado para a placa EP2C35F672C6 usando o Quartus II 13.0.1, outras placas da família podem conseguir executar o programa com algumas modificações, desde que o controlador ETHERNET seja o DM9000A. Placas mais recentes possuem outros controladores e podem usar componentes do Qsys mais recentes como Triple-Speed-Ethernet.

Alguns arquivos utilizados no desenvolvimento do projeto foram inclusos para referência, estão no diretório 'resources'. A explicação para algumas das decisões no projeto estão neles (como a necessidade de um PLL para SDRAM). O código está no diretório 'src', todas as instruções são relativas a esse diretório, a seguir as instruções para conseguir executar o projeto.

# Instruções
0. Clone esse repositório ou baixe o .zip em Code->Download ZIP
1. Abrir o arquivo de2_net.qpf no Quartus
2. Abrir o Qsys (Tools->Qsys)
3. Carregar o arquivo .qsys. 
    1. Acesse o menu File->Open
    2. Dentro do diretório qsys encontrará o arquivo system.qsys, selecione ele.
4. Se tiver componentes extras agora deve adicionar eles (recomendável testar o projeto como está antes de adicionar componentes customizados), na seção 'Componentes' existem informações úteis para isso.
5. Na aba Generation selecione VHDL para síntese e clique em Generate.
6. Feche o Qsys
7. No Quartus, adicione o .qip gerado pelo Qsys. 
    1. Acesse Project->Add/Remove Files in project...
    2. Selecione o botão [...] para achar o .qip. 
    3. Navegue até o diretório qsys/system/synthesis
    4. Mude o tipo de arquivo de Design Files para IP Variation Files
    5. Selecione o arquivo system.qip
    6. Selecione o botão Add em seguida OK
8. Compile o projeto (compilação completa não apenas síntese e análise) 
    1. Os pinos do top level são definidos automaticamente, desde que nomeados conforme o esquemático (disponível em resources/DE2/DE2_schematics.pdf)
9. Carregue o .sof na placa
    1. Certifique-se que a placa está conectada ao PC e ligada e que o cabo ethernet está conectada nela
    2. Abra o Programador (Tools->Programmer)
    3. Uma mensagem do OpenCore Plus irá aparecer (existem funcionalidades sendo utilizadas que são limitadas por tempo ou para avaliação) apenas dê OK
    4. O arquivo de2_net_time_limited.sof deve carregar automaticamente, caso não use o Add File... para adicionar, selecione o botão Start para carregar o programa. Caso o progresso não fique em '100%(Successful)' verifique se a placa está devidamente conectada ao PC.
    5. Deixe as janelas do programador e do OpenCore Plus abertas
10. Abra o Nios II (Tools->Nios II Software... ou pelo Windows)
11. Para Workspace do Eclipse selecione o diretório 'software' (deve ter apenas um diretório chamado base nele)
12. Criar nova aplicação + BSP
    1. Acesse File->New-> Nios II Application and BSP from Template
    2. Selecione o botão [...] para carregar o .sopcinfo, certifique-se de estar no diretório 'qsys' desse projeto (o Nios pode abrir um .sopcinfo antigo por padrão) o caminho deve ser algo como 'DE2_ETHERNET\src\qsys', selecione o arquivo system.sopcinfo
    3. Dê um nome ao projeto.
    4. Por padrão o Nios irá criar o projeto (e o BSP) no diretório 'qsys', para mudar isso desmarque a opção 'Use default location' e apague o 'qsys' do caminho em 'Project Location', isso irá colocar o projeto no diretório 'software' (o mesmo usado como Workspace do Eclipse). O caminho resultante deve ser algo como: DE2_ETHERNET\src\software\<nome_projeto>
    5. Como Template selecione Simple Socket Server (a primeira opção, não a com RGMII)
    6. Dê um Finish
13. O template do Nios foi desenvolvido para hardware mais recente usando periféricos que a DE2 não possui, algumas modificações são necessárias no projeto da aplicação (o BSP funciona normalmente). Existem duas opções:
    1. Apagar todos os arquivo .c e .h do projeto (o BSP deve continuar intacto) e copiar o conteúdo do diretório \src\software\base para o diretório do projeto \src\software\<nome_projeto>, em seguida no Nios dar um Refresh no projeto (botão direito->Refresh ou F5)
    2. Seguir os passos abaixo para converter manualmente, recomendável apenas caso queira entender melhor algumas partes do projeto.

1. Delete o arquivo tse_my_system (ele está relacionado ao Triple Speed Ethernet comentado, aqui estamos usando o DM9000A no lugar)
2. Delete o arquivo led.c (ele tem funcionalidades para manipular leds/7segmentos da placa no exemplo original, que não foram utilizados nessa versão simplificada)
3. O Template espera que a flash esteja nomeada como ext_flash no Qsys, mas foi nomeada cfi_flash (da sigla para Common Flash Memory Interface), por isso será necessário renomear os defines utilizados. Por curiosidade a Flash é utilizada (nesse caso) para obter o endereço MAC da placa armazenado no último setor da memória, se quiser diminuir ainda mais o código e deixar específico para uma placa é possível remover a Flash.
    1. No arquivo network_utilities.c troque as EXT_FLASH_NAME por CFI_FLASH_NAME e EXT_FLASH_BASE por CFI_FLASH_BASE
    2. Se você mudou o nome do componente no Qsys confira no arquivo system.h (no projeto do BSP) o nome dado
4. Agora é necessário remover o código relacionado aos LEDs 
    1. No arquivo simple_socket_server.c apague tudo menos a função SSSSimpleSocketServerTask() e os #include
        1. OBS: Se sua aplicação for complexa e precisar de outras tasks rodando, lembrando que esse exemplo tem um OS rodando com um escalonador para essas tasks,  o recomendado é criar elas na função SSSCreateTasks(), se elas não fazem uso de sockets (usar TK_NEWTASK caso usem como é o caso da task principal), o exemplo mostra como criar duas tasks
    2. No arquivo iniche_init.c (considere como main.c) apague as chamadas para SSSCreateOSDataStructs() e SSSCreateTasks(), caso não esteja usando, dentro da função SSSInitialTask()
    3. (Opcional, mas recomendado) No arquivo simple_socket_server.h apague a declaração de todas as funções menos SSSSimpleSocketServerTask(), apague os defines de TASK_PRIORITY, exceto o SSS_INITIAL_TASK_PRIORITY apague também tudo abaixo da linha `#define TASK_STACKSIZE 2048`, são definições relacionadas aos LEDs e as estruturas para controle do servidor mais complexas que não são necessárias. 
        1. OBS1: Certifique-se de não apagar a diretiva #endif, logo acima da licença.
        2. OBS2: Se quiser desativar o cliente DHCP  é nesse arquivo que é definido o IP estático, juntamente com gateway e a máscara.
    
5. No arquivo simple_socket_server.c está a função SSSSimpleSocketServerTask() ela é chamada assim que toda a inicialização é feita, nela você deve colocar seu código para fazer uso de socket. Se quiser utilizar como está é necessário redefinir a struct SSSConn no arquivo simple_socket_server.h, porém ela é mais complexa que o necessário para a maioria dos casos. Caso queira, um exemplo pronto para um CLIENTE TCP está em software/base/simple_socket_server.c
14. Agora o projeto pode compilar, no entanto ainda não foi adicionado o código para o controlador DM900A:
    1. Copie os todos os 4 arquivos no diretório software/DM9000A para o diretório do projeto (software/<nome_projeto>)
    2. Selecione o projeto no Project Explorer e aperte F5 para recarregar, os arquivos devem aparecer no explorador, se isso não der certo clique no projeto com botão direito e selecione Refresh
15. Por fim na função main no arquivo iniche_init.c é necessário definir uma instância e inicializar o controlador para isso cole as duas linhas abaixo no começo da função
```c
DM9000A_INSTANCE( DM9000A_0, dm9000a_0 );
DM9000A_INIT( DM9000A_0, dm9000a_0 );
```
 é preciso incluir o arquivo "dm9000a.h" também

16. Depois de seguir os passos, ou copiar o código pronto, o projeto está pronto. Agora compile o BSP e o projeto, nessa ordem, pode dar build indidual ou Project->Build All (ou Ctrl+B)
17. Caso não funcione, vá para a seção possíveis problemas.

# Possíveis problemas
Caso ocorra alguma problema tente alguma das soluções abaixo:
1. Verifique se o led no conector RJ-45 está piscando, se não estiver estiver tente reiniciar a placa (provavelmente o cabo não estava conectado no momento de programar a placa)
    1. Primeiro na janela do OpenCore Plus aperte Cancel
    2. Reinicie a placa
    3. Carregue novamente o programa
    5. No Nios de Run As->Nios II Hardware
2. Caso tenha algum problema com :
    1. No arquivo simple_socket_server.h preencha as diretivas #define IPADDR0, IPADDR1 ... GWADDDR3 de acordo com sua rede, provavelmente será algo semelhante ao exemplo no comentário logo acima. Para verificar abra o Prompt de comando ou Powershell e digite o comando `ipconfig` procure na interface que esta utilizando o campo Default Gateway deve ser algo parecido com 192.168.0.1 ou 192.168.1.1 use isso nos #define GWADDR0-3 separando cada octeto em um define, por exemplo:
    ```c
    #define GWADDR0   192
    #define GWADDR1   168
    #define GWADDR2   0
    #define GWADDR3   1
    ```
    2. De modo semelhante defina o IP (que deve estar na mesma sub-rede)
    3. Na janela do OpenCore Plus (abertar ao programar a placa) aperte em close e reinicie a placa, quando ela ligar novamente carregue o program denovo (sem altera nada, apenas de Start)
    3. Agora é necessário atualizar o BSP, para isso clique com botão direito no BSP do projeto no explorador do Nios, na janela do Editor clique na aba Software Packages e desabilite a opção 'enable_dhcp_client'
    4. Clique en Exit, confirme para salvar. (Não gere o BSP ainda)
    5. De um clean (botão direito->Clean Project) no BSP e de um Build
    6. Faça o mesmo com a aplicação 