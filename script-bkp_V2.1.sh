#!/bin/bash

source script.conf
#CARREGA O CONF DO SCRIPT

# FUNCAO CRIA PASTA DIARIA Com a 

	function @CRIAPASTADIARIA () {
		mkdir -p /$PBACKUP/$DATA 
		}

# FUNCAO HORA
        function @HORA () {
                HORA=`date +%H:%M`
                }


#FUNCAO COMPACTA PASTAS
 	function @BACKUPPASTAS () {


                for PASTA in `cat $ARQUIVO`; do

                        LOCAL=`echo $PASTA |awk -F / {'print $NF'}`

                        echo "" >> $LOG
                        echo " Efetuando Backup da pasta $PASTA" >> $LOG
                        echo "" >> $LOG

                        tar -czf $PBACKUP/$DATA/$LOCAL.tar.gz $PASTA
			echo "Escrevendo backup diario em $PBACKUP" >> $LOG
                done;
		
                }


#FUNCAO RODA RSYNC 

	function @RODARSYNC() {
		
		echo " " >> $LOG
		echo " " >> $LOG
		echo "|-----------------------------------------------" >> $LOG
		echo " Sincronização iniciada em $DATA $HORAAT" >> $LOG


		sudo rsync -Cravzp $PBACKUP   $USER@IPSERVER:$DIRDESTINO >> $LOG
		if [ $? = 0 ]; then

			echo " Sincronização Finalizada em $DATA $HORAAT" >> $LOG
	                echo "|-----------------------------------------------" >> $LOG
        	        echo " " >> $LOG
                	echo " " >> $LOG
               		echo " deletando backups Locais de $PBACKUP $DATA $HORAAT" >> $LOG
                	echo "Backup Deletado com Sucesso de $PBACKUP" >> $LOG
                	echo "Enviando Email de informação para o Administrador" >> $LOG
                	echo "" >> $LOG
			@ENVIAEMAIL

                else
                        echo "Sincronização Mau concluida $DATA $HORAAT" >> $LOG
                        @ENVIAMAILPROBLEMA
                fi


		rm -rf /$PBACKUP/*

		}


#FUNCAO QUE ENVIA EMAIL PARA O ADMINISTRADOR
	function @ENVIAEMAIL () {


		ASSUNTO="$HOSTNAME - $1"
		MENSAGEM=$2

		if [ "$1" == "" ] ;then
		ASSUNTO="BKP DIARIO LIFE"
		fi
		if [ "$2" == "" ] ;then
		$MENSAGEM
		fi
		if [ "$3" != "" ] ;then
		MENSAGEM="$2 `cat $3`"
		fi

		sendemail -f $EMAIL_FROM -t $EMAIL_TO -u "$ASSUNTO" -m "$MENSAGEM" $ANEXO -a $LOG  -o tls=yes  -s $SERVIDOR_SMTP -xu $EMAIL_FROM -xp $SENHA
		echo "Email Enviador com Sucesso para $EMAIL_TO" >> $LOG
		echo " Deletando Arquivo de log do local" >> $LOG	
		rm -rf $LOG
		}


#FUNCAO QUE ENVIA EMAIL DE PROBLEMA CASO NÃO FOR FEITO O RSYNC COM SUCESSO
 function @ENVIAMAILPROBLEMA () {


                ASSUNTO="$HOSTNAME - $1"
                MENSAGEM=$2

                if [ "$1" == "" ] ;then
                ASSUNTO="BKP DIARIO LIFE"
                fi
                if [ "$2" == "" ] ;then
                MENSAGEM=" ERRO AO FAZER A SINCRONIZAÇÃO DOS DADOS - VERIFIQUE A CONDEXAO COM O SERVIDOR" >> $LOG
                fi
                if [ "$3" != "" ] ;then
                MENSAGEM="$2 `cat $3`"
                fi

                sendemail -f $EMAIL_FROM -t $EMAIL_TO -u "$ASSUNTo" -m "$MENSAGEM" $ANEXO -a $LOG  -o tls=yes  -s $SERVIDOR_SMTP -xu $EMAIL_FROM -xp $SENHA

		}




@CRIAPASTADIARIA
@BACKUPPASTAS
@RODARSYNC


