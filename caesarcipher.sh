# -------------------------------------------------
# #!/usr/bin/env bash
# --------------------------------------------------
# Projeto : Cifra de Cesar
# Arquivo : caesarcipher.sh
# Descrição: Cifra e decifra textos(apenas letras) conforme a cifra de cesar
# Versão: 0.9.0
# Data : (automático)
# Autor : Rodrigo da Matta Soares <rodrigo.matta.soares@gmail.com>
# Licença : GNU/GPL v3.0
# --------------------------------------------------
# Uso: caesarcipher.sh NÚMERO{1-25} -h (-f ARQUIVO + TEXTO)...
# --------------------------------------------------
# 
#  FALTA FAZER: 
#   - Testar se o  'pt_BR.UTF-8' está disponivel no sistema
#   - Adicionar o opção -d
# -------------------------------------------------

# Acionar para debugar de forma mais avançada
# set -Eeuo pipefail
# trap 'echo "${BASH_SOURCE}:${LINENO}:${FUNCNAME:-}"' ERR

#------------------- DECLARAÇÕES DE VARIÁVEIS E FUNÇÕES INICIAIS

#Limite de entrada de cartacteres
declare -i limite_entrada=100000

# Caracteres que não passaram pelo processo de cifragem, mas são aceitos e armazenados em $palavra_cifrada da forma que estão
caracteres_especiais='-., _@*0-9'$'\n'

# Caracteres que seram aceitos como parametros de entrada
padrao_de_entrada_aceito="-., _@0-9*a-zA-Záàâãêéíú"$'\n'

# Quantidade de deslocamento que será feito sobre cada letra
deslocamento=

# No final $palavra_cifrada conterá o resultado que nos interessa
palavra_cifrada=''

# Variavel que conterá a cifra no final
declare -l palavra_sem_cifra=''

# Define LC_ALL para a charset pt_BR.UTF-8...
LC_ALL='pt_BR.UTF-8'

# O deslocamento da cifragem será feito com base nos indices do caracteres dos alfabetos
alfabeto='abcdefghijklmnopqrstuvwxyz'
declare -A alfabeto_array=([a]=0 [b]=1 [c]=2 [d]=3 [e]=4 [f]=5 [g]=6 [h]=7 [i]=8 [j]=9 [k]=10 [l]=11 [m]=12 [n]=13 [o]=14 [p]=15 [q]=16 [r]=17 [s]=18 [t]=19 [u]=20 [v]=21 [w]=22 [x]=23 [y]=24 [z]=25 [á]=0 [à]=0 [â]=0 [ã]=0 [ê]=4 [é]=4 [í]=8 [ó]=14 [ô]=14 [ú]=20)

# Mensagens de erro
erro(){
    
    msg_erro[1]='O primeiro parametro deve ser um número entre 1 e 25'
    msg_erro[2]="Os caracteres de entrada devem ser, incluindo espaço, os seguintes: $padrao_de_entrada_aceito"
    msg_erro[3]="O texto de entrada deve conter de 1 a $limite_entrada caracteres"
    msg_erro[4]='O charset pt_BR.UTF-8 não está disponível no sistema'
    msg_erro[5]='Aquivo de entrada não encontrado'

	echo ${msg_erro[$1]} 
    exit $1
}

# Mensagem de ajuda
help="\r
\r\rUso: caesarcipher.sh NÚMERO{1-25} [-f ARQUIVO] TEXTO...\n\n

\rOpções:\n\n

    \t-d, --decifrar \t    Decifra a cifra passada, ou cifra em ordem reversa\n
    \t-f, --file     \t\t  Aceita o arquivo informado como entrada\n
    \t-h, --help     \t\t  Mosnulotra esse mensagem e sai\n\n

\rExemplos de uso:\n\n

    \tcaesarcipher.sh 12 texto que será cifrado                 \t\t\t       #Cifra o texto mostrando a saída: fqjfa cgq eqdm ourdmpa\n\n

    \tcaesarcipher.sh 12 -f arquivo.txt                         \t\t\t\t     #Cifra o texto do arquivo \n\n

    \tcaesarcipher.sh 12 -f arquivo.txt texto que será cifrado  \t           #Cifra o texto do arquivo mais o texto juntos\n\n

    \tcaesarcipher.sh -d 12 fqjfa cgq eqdm ourdmpa \t\t\t                    #Decifra o texto mostrando a saída: texto que será cifrado\n\n

    \tcaesarcipher.sh -d 12 -f arquivo.txt \t\t\t\t                          #Decifra o texto do arquivo\n\n

    \tcaesarcipher.sh -h \t\t\t\t\t\t                                        #Mostra essa mensagem e sai\n\n

\rObservações: \n\n

    \t1 - A ordem das opções devem ser respeitadas, caso não, as opções serão cifrados como caracteres qualquer ou ocorrerá erro!\n\n

    \t2 - Só são aceitos caracteres de entrada, incluindo espaços, dentro do seguinte padrão regex:  ^[$padrao_de_entrada_aceito]+$\n\n
    
    \t3 - Apenas as letras sofrem cifragem, o restante dos caractes especiais aceitos são mantidos em seus estados originais\n\n

    \t4 - Foi estabelecido um limite de caracteres de entrada de $limite_entrada caracteres\n\n

    \t5 - O charset pt_BR.UTF-8 deve está disponivél no sistema para ser configurado temporariamente na variável LC_ALL\n\n

    \t6 - A saída do programa é enviada para a STDOUT
"

#------------------- DECLARAÇÕES DE VARIÁVEIS E FUNÇÕES FIM




#--------------------TESTES E ENTRADAS DE DADOS

# Recebe dados pela STDIN
if [[ -p /dev/stdin ]]
then
    palavra_sem_cifra=$(< /dev/stdin)
fi
if [[ ! -t 0 && ! -p /dev/stdin ]]
then
    palavra_sem_cifra=$(< /dev/stdin)
fi

# Testes do primeiro parametro - exibe ajuda ou atribui $1 a deslocamento
if [[ $1 =~ ^[1-9]{1,2}$  && $1 -ge 1 && $1 -le 25 ]]
then 
    deslocamento=$1 ; shift
elif [[ $1 = -h || $1 = --help ]] 
then
    echo -e $help ; exit 0
else
    erro 1
fi

# Adiciona valor da palavra_sem_cifra
while true ; do
    case $1 in
        #  -d | --decifrar) ainda será feito ; shift ;;
        -f | --file) shift ; [[ -f $1 ]] && { palavra_sem_cifra=$(< $1) ; shift ; } || erro 5 ;&
        *) palavra_sem_cifra+="$@" && set -- ;;
    esac
    [[ -n $1 ]] || break
done

# Valida se os caracteres são aceitos como entrada
[[ $palavra_sem_cifra =~ ^[$padrao_de_entrada_aceito]+$ ]] || erro 2

# Valida tamanho da entrada
[[ ${#palavra_sem_cifra} -ge 1 && ${#palavra_sem_cifra} -le $limite_entrada  ]] || erro 3

#--------------------TESTES E ENTRADAS DE DADOS FIM




#--------------------EXECUÇÃO

# Correr por cada letra do texto de entrada
for (( i=0 ; i<${#palavra_sem_cifra} ; i++ ))
do
    # A letra de vez é armazena em $letra por questões de legibilidade
    letra="${palavra_sem_cifra:$i:1}"

    # Se encontrar caracteres especiais é para acresentar ele diretamente na $palavra_cifrada e pular para o próximo loop
    [[ $letra == [$caracteres_especiais] ]] && { palavra_cifrada+=$letra ; continue ; }
   
    # O index da letra é pego
    index=${alfabeto_array[$letra]}

    # É somado ao $index o valor de deslocamento $deslocamento.
    index_cifrado=$(( ( index + deslocamento ) % 26 ))

    # O texto cifrado vai sendo armazenado letra por letra em $palavra_cifrada
    palavra_cifrada+="${alfabeto:$index_cifrado:1}"

done

echo "$palavra_cifrada"

LC_ALL=''

#--------------------EXECUÇÃO FIM

