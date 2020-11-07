# Ambiente
O projeto foi desenvolvido e testado para a placa EP2C35F672C6 usando o Quartus II 13.0.1 no Windows 10.  
Outras placas da família podem conseguir executar o programa com algumas modificações, desde que o controlador ETHERNET seja o DM9000A.  
Placas mais recentes possuem outros controladores e podem usar componentes do Qsys mais recentes como Triple-Speed-Ethernet.

# Estrutura do repositório
## Diretório **resources**
Nesse diretório estão arquivos, no formato PDF, contendo manuais, datasheets, esquemáticos e outros recursos utilizados durante o desenvolvimento desse projeto.  
A explicação para algumas decisões no projeto estão neles, por exemplo, a necessidade de um PLL para gerar o Clock para SDRAM).
## Diretório **example**
Nesse diretório estão dois arquivos Python de exemplo de aplicação para comunicar com a placa.  
O arquivo tcp_client.py cria um cliente TCP com dois parâmetros, o IP do servidor(identificado pela variável *HOST*) e a porta em que o servidor está escutando (identificada pela variável *PORT*).  
O arquivo tcp_server.py cria um servidor TCP com um parâmetro apenas, a porta em que o servidor irá escutar. Por padrão ele irá escutar em todas as interfaces, indicado pelo IP vazio(interpretado como 0.0.0.0), a portão padrão é 5000, para maioria dos casos não é necessário alterar, a não ser que outro serviço já esteja rodando nessa porta, o programa irá lançar uma exceção informando isso e irá fechar.
## Diretório **src**
Nesse diretório está o código do projeto. Na raíz do diretório está o arquivo VHDL Top Level (e dois arquivos de projeto do Quartus) e 3 diretórios:
1. **hardware**: Destinado a arquivos .vhdl ou .v utilizados pelo Quartus. Inicialmente já contém 2 diretórios **PLL** e **DELAY**, que contém código para componentes utilizados no Top Level do Quartus
2. **qsys**: Destinado a arquivos gerados ou usados pelo Qsys. Inicialmente contém o arquivo system.qsys e um diretório **DM9000A** que contém o código para o componente que representa o controlador ETHERNET da placa. É recomendado armazenar os componentes customizados no diretório **qsys**, mas não é obrigatório.
3. **software**: Destinado a arquivos gerados ou usados pelo Nios 2. Inicialmente contém um diretório **base** que contém arquivos .c e .h para serem utilizados para criar o projeto no Nios, mais informações na seção [Compilando](#Compilando). 
## Diretório **bin**
Nesse diretório estão dois arquivos .sof e .elf, esses dois arquivos são suficientes para executar o programa, permitindo ver o resultado, mas não modificar o código fonte. É útil para testar se o ambiente de desenvolvimento (a sua rede local, a placa, o Quartus e o Nios2) está OK. 

# Executando
O projeto exige basicamente duas partes, um cliente e um servidor. Nesse exemplo o cliente está implementado em C e roda na placa, enquanto o servidor está implementado em Python e roda na sua máquina. Para executar a demonstração siga esses passos:
1. Carregue o .sof
    1. Certifique-se que a placa está conectada ao PC e ligada e que o cabo ethernet está conectada nela
    2. Abra o Quartus
    3. Abra o Programmer (Tools->Programmer)
    4. Selecione Add File...
    5. Selecione o arquivo de2_net_time_limited.sof dentro do diretório **DE2_ETHERNET\bin**.
    6. Uma mensagem do OpenCore Plus irá aparecer (existem funcionalidades sendo utilizadas que são limitadas por tempo ou para avaliação) apenas dê OK
    7. Selecione Start, caso o progresso não fique em '100%(Successful)' verifique se a placa está devidamente conectada ao PC. 
    8. Deixe as janelas abertas do programador e OpenCore Plus.
2. Inicie o servidor TCP
    1. É necessário ter Python3 instalado, pode ser instalado pelo site oficial ou pela Microsoft Store. 
    2. Com Python instalado abra um terminal no diretório **DE2_ETHERNET\example** e execute o comando python tcp_server.py
    3. A mensagem "Esperando conexao..." deve aparecer no terminal se tudo der certo.
3. Encontrar o IP do servidor
    1. O servidor irá escutar em todas as interfaces por padrão, mas o cliente precisa saber qual o IP.
    2. Em um terminal no Windows digite o comando `ipconfig` e encontre o campo *IPv4 Address* esse é o IP do servidor, ele será necessário no passo seguinte.
4. Carregue o .elf 
    1. Abra o Nios II Command Shell, para isso faça uma pesquisa no Windows por Nios II, não é necessário abrir o Eclipse, apenas o shell.
    2. No terminal mude o diretório para **DE2_ETHERNET\bin**, por padrão deve estar em **/cygdrive/c/altera/13.0sp1**
        1. Dica: Para mudar de disco use `cd a:`, por exemplo para mudar para o disco A, útil caso o projeto não esteja no disco C.
    3. Digite o comando `nios2-download -g base_ethernet.elf && nios2-terminal.exe` ou copie e cole (botão direito cola no terminal)
    4. Se tudo der certo o processo de download irá iniciar e eventualmente receberá a mensagem "Informe o IP (no formato 192.168.0.2):" informe aqui o IP obtido anteriormente no formato indicado.  
    OBS: Não existe feedback visual nesse terminal, ou seja, o que você escrever não é apresentado no terminal, mas após pressionar ENTER o dado será enviado normalmente.
    5. Se o IP informado estiver correto o cliente irá começar a receber mensagens do servidor que serão impressas no terminal.
# Compilando
0. Clone esse repositório ou baixe o .zip em Code->Download ZIP
1. Abrir o arquivo de2_net.qpf no Quartus
2. Abrir o Qsys (Tools->Qsys)
3. Carregar o arquivo .qsys. 
    1. Acesse o menu File->Open
    2. Dentro do diretório **\src\qsys** encontrará o arquivo system.qsys, selecione ele.
4. Se tiver componentes extras agora deve adicionar eles (recomendável compilar o projeto como está antes de adicionar componentes customizados).
5. Na aba Generation na seção *Synthesis* selecione VHDL para síntese, desmarque a opção para gerar o arquivo .bsf e clique em Generate.
6. Feche o Qsys
7. No Quartus, adicione o .qip gerado pelo Qsys. 
    1. Acesse o menu Project->Add/Remove Files in Project... ou use o atalho Ctrl+Shift+E
    2. Selecione o botão [...] para achar o .qip. 
    3. Vá até o diretório **\src\qsys\system\synthesis**
    4. Mude o tipo de arquivo de Design Files para IP Variation Files
    5. Selecione o arquivo system.qip
    6. Selecione o botão Add em seguida OK
8. Compile o projeto (compilação completa não apenas síntese e análise) 
    1. Acesse o menu Processing->Start compilation ou use o atalho Ctrl+L
    2. Os pinos do top level são definidos automaticamente, desde que nomeados conforme o esquemático (arquivo DE2_schematics.pdf no diretório **\resources\DE2**)

9. Abra o Nios II (Tools->Nios II Software... ou pelo Windows)
10. Para Workspace do Eclipse selecione o diretório **\src\software** (deve ter apenas um diretório chamado base nele)
11. Criar nova aplicação + BSP
    1. Acesse File->New-> Nios II Application and BSP from Template
    2. Selecione o botão [...] para carregar o .sopcinfo, certifique-se de estar no diretório **\src\qsys** desse projeto (o Nios pode abrir um .sopcinfo antigo por padrão) o caminho deve ser algo como **DE2_ETHERNET\src\qsys**, selecione o arquivo system.sopcinfo
    3. Dê um nome ao projeto. O nome não pode ser 'base', pois o diretório já existe, ou então renomeie o diretório existente.
    4. Por padrão o Nios irá tentar criar o projeto (e o BSP) no diretório **\src\qsys\software**, para mudar isso desmarque a opção 'Use default location' e apague o '\qsys' do caminho em 'Project Location'. O caminho resultante deve ser algo como: **DE2_ETHERNET\src\software\\<nome_projeto>**
    5. Como Template selecione Simple Socket Server (a primeira opção, não a com RGMII)
    6. Dê um Finish
12. O template do Nios foi desenvolvido para hardware mais recente usando periféricos que a DE2 não possui, algumas modificações são necessárias no projeto da aplicação (o BSP funciona normalmente). Para isso existem duas abordagens:
    1. Apagar todos os arquivo .c e .h do projeto (o BSP deve continuar intacto) e copiar todo o conteúdo do diretório **\src\software\base** para o diretório do projeto **\src\software\\<nome_projeto>**, em seguida, no Nios, atualizar o projeto usando o atalho F5 (ou clique com botão direito no projeto e selecione Refresh).
    2. Ou seguir os passos na seção abaixo para converter manualmente, recomendável apenas caso queira entender melhor algumas partes do projeto.

A seguir estão os passos para converter manualmente, se você escolheu a primeira opção e já copiou o conteúdo necessário vá para o passo 13.
## Alterando o template manualmente
1. Delete o arquivo tse_my_system (ele está relacionado ao Triple Speed Ethernet comentado, aqui estamos usando o DM9000A no lugar)
2. Delete o arquivo led.c (ele tem funcionalidades para manipular leds/7segmentos da placa no exemplo original, que não foram utilizados nessa versão simplificada)
3. O template espera que a Flash esteja nomeada como ext_flash no Qsys, mas foi nomeada cfi_flash (da sigla para Common Flash Memory Interface), por isso será necessário renomear os defines utilizados.  
A memória Flash é utilizada (nesse caso) para obter o endereço MAC da placa, armazenado no último setor da memória.  
    1. No arquivo network_utilities.c troque as constantes `EXT_FLASH_NAME` por `CFI_FLASH_NAME` e `EXT_FLASH_BASE` por `CFI_FLASH_BASE`
    2. Se você mudou o nome do componente no Qsys confira no arquivo system.h (no projeto do BSP) o nome dado   
Nota: se quiser diminuir ainda mais o código e deixar específico para uma placa é possível remover a Flash(no total são 3 componentes no Qsys), alterar a função `get_board_mac_addr()` em network_utilities.c para o endereço MAC da sua placa específica e assim pode apagar todo o resto do conteúdo do arquivo network_utilities.c, no entanto será necessário adicionar outra memória para o CPU, pois a Flash também está sendo usada para isso.
4. Agora é necessário remover o código relacionado aos LEDs 
    1. No arquivo simple_socket_server.c apague tudo menos a função `SSSSimpleSocketServerTask()` e os `#include`
        1. OBS: Se sua aplicação for complexa e precisar de outras tasks rodando(esse exemplo tem um OS rodando com um escalonador para essas tasks)  o recomendado é criar elas na função `SSSCreateTasks()`, se elas não fazem uso de sockets.  
        O exemplo mostra como criar duas tasks, use ele como referência se necessário. OBS: Essas tarefas não irão funcionar, pois elas estão usando LEDs que não existem nesse projeto.  
        Se as tarefas fizerem uso de socket as tarefas/funções devem ser criadas usando `TK_NEWTASK`, como é o caso da task principal. 
    2. Na função `SSSSimpleSocketServerTask()` apague a linha `static SSSConn conn;` ela está definindo a estrutura utilizada pelo exemplo para gerenciar as conexões, mas é mais complexa que o necessário na maioria dos casos (novamente, se sua aplicação exigir gerenciamento mais elaborado você pode considerar manter o código). Apague também a declaração da variável `max_socket`, juntamente com todo o loop `while(1)` no final da função. Por fim remova a chamada da função `sss_reset_connection()`.
    3. No arquivo iniche_init.c (considere como main.c) apague as chamadas para `SSSCreateOSDataStructs()` e `SSSCreateTasks()`, caso não esteja usando, dentro da função `SSSInitialTask()`
    4. No arquivo simple_socket_server.h apague a declaração de todas as funções menos `SSSSimpleSocketServerTask()`, apague os todos `#defines
     *_TASK_PRIORITY`, exceto o **SSS_INITIAL_TASK_PRIORITY** apague também tudo abaixo da linha `#define TASK_STACKSIZE 2048`, são definições relacionadas aos LEDs e as estruturas para controle do servidor mais complexas que não são necessárias. 
        1. OBS1: Certifique-se de não apagar a diretiva #endif, logo acima da licença.
        2. OBS2: Se quiser desativar o cliente DHCP  é nesse arquivo que é definido o IP estático, juntamente com gateway e a máscara. No entanto nos testes realizados remover o cliente DHCP gera problemas com o endereço MAC também(aparentemente) e o programa deixa de funcionar.
    
5. No arquivo simple_socket_server.c está a função `SSSSimpleSocketServerTask()` ela é chamada assim que toda a inicialização é feita, nela você deve colocar seu código para fazer uso de socket. Um exemplo pronto para um CLIENTE TCP está em software/base/simple_socket_server.c copie o conteúdo da função `MainTask()` (ela apenas foi renomeada no meu exemplo) na função `SSSSimpleSocketServerTask()`
    1. Se quiser renomear também a função você deve alterar a declaração da função no arquivo simple_socket_server.h, em seguida no arquivo iniche_init.c alterar `TK_ENTRY(SSSSimpleSocketServerTask);` e na struct ssstask alterar o terceiro campo de SSSSimpleSocketServerTask para o nome dado para a função.
6. Agora é necessário adicionar o código para o controlador DM9000A:
    1. Vá até o diretório **\src\software\base** e copie o diretório **DM9000A** (o diretório em si, não apenas o conteúdo) para o diretório **\src\software\\<nome_projeto>**
    2. No Nios perte F5 (ou botão direito->Refresh) para recarregar, o diretório DM9000A com os arquivos deve aparecer no Project Explorer, se isso não funcionar crie um diretório com o mesmo nome através do Project Explorer, crie os arquivo manualmente e copie o conteúdo.
7. Por fim na função main no arquivo iniche_init.c é necessário definir uma instância e inicializar o controlador para isso cole as duas linhas abaixo no começo da função (logo após a declaração da variável error_code)
```c
DM9000A_INSTANCE( DM9000A_0, dm9000a_0 );
DM9000A_INIT( DM9000A_0, dm9000a_0 );
```
 é preciso incluir o header também. Após a linha `#include "includes.h"` adicione a linha `#include "DM9000A/dm9000a.h"`. OBS: Alguns includes exigem certa ordem que o programa funcione corretamente.

13. Agora compile o BSP e o projeto, nessa ordem. Pode dar build individualmente ou no menu Project->Build All (ou ainda usando Ctrl+B).
14. Carregue o .sof na placa de maneira análoga à da seção [Executando](#Executando), mas o arquivo .sof deve abrir automaticamente nesse caso.
15. Por fim carregar o .elf na placa como já explicado, ou pelo Eclipse:
    1. Acesse o menu Run->Run Configurations...
    2. Clique 2x em Nios II Hardware, isso irá criar uma nova configuração chamada 'New_configuration'
    3. Na aba Target Connection selecione 'Refresh Connection' uma nova entrada deve aparecer 
    4. Selecione Apply e Run
16. Se deixar o programa rodando sem um servidor ele irá eventualmente falhar e uma série de mensagens de erro serão apresentadas, para o teste completo é possível usar Python seguindo os passos apresentandos na seção [Executando](#Executando) é possível executar também no Command Shell, no entanto pode ser mais útil carregar pelo Eclipse e usar o Nios console, que tem feedback visual.

# Possíveis problemas
1. Se tiver algum problema rodando o programa (após dar Run as -> Nios II Hardware) relacionado ao ID do sistema
    1. Vá para Run Configurations
    2. Na aba Target Connect na seção *System ID checks* marque as duas opções 
2. Se o Nios II Console parar em **IP address of et1 : 0.0.0.0** é possível que houve um problema com a interface, os LEDs do conector da placa não devem estar acessos, confirmando que não está funcionando. Esse problema também ocorre quando o arquivo .sof é carregado na placa antes de abrir o Nios, ou quando o Nios decide não funcionar direito.
    1. Pare o programa (botão vermelho na direita do Nios II Console)
    2. Volte para a janela do OpenCore Plus e aperte Cancel
    3. Desligue a placa e ligue novamente
    4. Carregue o programa novamente, apertando o Start
    5. Tente rodar novamente o programa no Nios (Run As -> Nios II Hardware)
3. Caso tenha algum problema com o DHCP é possível tentar usar um IP estático, mas como informado não consegui fazer o programa funcionar dessa forma, pode ser um problema local ou o código não acomada essa alteração. No entanto após as últimas alterações de código não houve problema com o DHCP nos testes realizados:
    1. No arquivo simple_socket_server.h preencha as diretivas #define IPADDR0, IPADDR1 ... GWADDDR3 de acordo com sua rede, provavelmente será algo semelhante ao exemplo no comentário logo acima. Para verificar abra o Prompt de comando ou Powershell e digite o comando `ipconfig` procure na interface que esta utilizando o campo Default Gateway deve ser algo parecido com 192.168.0.1 ou 192.168.1.1 use isso nos `#define GWADDR0-3` separando cada octeto em um define, por exemplo:
    ```c
    #define GWADDR0   192
    #define GWADDR1   168
    #define GWADDR2   0
    #define GWADDR3   1
    ```
    2. De modo semelhante defina o IP (que deve estar na mesma sub-rede)
    3. Na janela do OpenCore Plus (aberta ao programar a placa) aperte em Close e reinicie a placa, carregue o programa novamente (sem alterar nada, apenas dê Start)
    3. Agora é necessário atualizar o BSP, para isso clique com botão direito no BSP do projeto no explorador do Nios, na janela do Editor clique na aba Software Packages e desabilite a opção 'enable_dhcp_client'
    4. Clique en Exit, confirme para salvar. (Não gere o BSP ainda)
    5. De um clean (botão direito->Clean Project) no BSP e de um Build
    6. Faça o mesmo (Clean + Build) com a aplicação 
    7. É possível que seja necessário mais algum passo que desconheço para que isso funcione.
4. É possível que o no console do Nios aparece uma mensagem informando que conseguiu um IP via DHCP, mas o IP não é apresentado, esse erro costuma ocorrer caso tenha modificado manualmente os arquivos e na função `SSSSimpleSocketServerTask()` deixou o código original, alterar o conteúdo como sugerido resolve (usando o conteúdo do arquivo no diretório **\src\software\base**), não foi identificado o que causa esse comportamento.
5. Em algumas situações o Nios indica visualmente erros que não ocorriam antes, por exemplo, não acha determinados símbolos(funções, variáveis, etc), muitas vezes ele compila normalmente, confirmado observado a mensagem de 'Build finished' sem erros na aba 'Console' e o programa pode ser carregado normalmente. 