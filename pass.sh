#!/bin/bash

PASSWORDS_FILE="/home/`whoami`/Documents/passes.txt"
GPG_PASSWORDS_FILE="/home/`whoami`/Documents/passes.gpg"
EDITOR_APP="vim" # Make sure that your editor start with a new instance (ex. kate --new)
SHRED_ITERATIONS="5" # number passed to shred --iterations
ENCRYPT_PASS=""

function generate_password
{
    echo -en "\e[1m\e[1m""[*] Password: ""\e[1m\e[0m"
    read -s gpg_password

    ENCRYPT_PASS="`echo -n $gpg_password |sha512sum -t|cut -d- -f1 | tr -d '\n'| tr -d ' '`"
    gpg_password=""

    echo
    echo
}

function echo_restore
{
    echo -en "\e[1m\e[0m""$1"
}

function echo_white
{
    echo -e "\e[1m\e[1m""$1""\e[1m\e[0m"
}

function echo_green
{
    echo -e "\e[1m\e[32m""$1""\e[1m\e[0m"
}

function echo_red
{
    echo -e "\e[1m\e[31m""$1""\e[1m\e[0m"
}

function edit_file
{
    if [ -s $PASSWORDS_FILE ] && [ -s $GPG_PASSWORDS_FILE ]; then
        echo_red '[-] Both encrypted and decrypted files exists'
        exit -3
    fi

    if [ -s $GPG_PASSWORDS_FILE ]; then
        echo_white "[*] Edit encrypted file: $GPG_PASSWORDS_FILE"
        generate_password

        echo "[+] Decrypt file: $GPG_PASSWORDS_FILE"

        echo $ENCRYPT_PASS | gpg --batch --passphrase-fd 0 --decrypt --output $PASSWORDS_FILE $GPG_PASSWORDS_FILE 1>/dev/null 2>&1

        if [ $? != 0 ]; then
            echo_red '[-] Error: file not decrypted'
            exit 2
        fi
    else
        if [ -s $PASSWORDS_FILE ]; then
            echo_white "[*] Edit passwrods file: $PASSWORDS_FILE"
        else
            echo_white "[*] Create empty passwords file: $PASSWORDS_FILE"
        fi
        echo_white '[*] Please choose a password that will be used to encrypt the passwords file'
        echo_red "[*] Note: File at $PASSWORDS_FILE will be deleted after encryption"

        generate_password
    fi

    #date="`date +"%d/%m/%Y"`"
    #grep $date $PASSWORDS_FILE > /dev/null 2>&1
    #if [ $? != 0 ]; then
    #    echo_green "[+] Add changelog date"
    #    echo "$date:" >> $PASSWORDS_FILE
    #fi

    file_hash=`md5sum $PASSWORDS_FILE`

    echo "[+] Start editing"
    $EDITOR_APP $PASSWORDS_FILE 2>/dev/null

    if [ "$file_hash" == "`md5sum $PASSWORDS_FILE`" ]; then
        echo_red "[-] File not changed"
        echo_green "[+] Delete decrypted file: $PASSWORDS_FILE"
        shred -u -n $SHRED_ITERATIONS $PASSWORDS_FILE
        exit 0
    fi

    echo "[+] Delete old encrypted file: $GPG_PASSWORDS_FILE"
    rm -fv $GPG_PASSWORDS_FILE

    echo "[+] Encrypt new file: $PASSWORDS_FILE"
    echo $ENCRYPT_PASS | gpg --batch --passphrase-fd 0 --symmetric --output $GPG_PASSWORDS_FILE $PASSWORDS_FILE 1>/dev/null 2>&1

    if [ $? == 0 ]; then
        echo_green "[+] Delete decrypted file: $PASSWORDS_FILE"
        shred -u -n $SHRED_ITERATIONS $PASSWORDS_FILE
    else
        echo_red '[-] Error: file note encrypted'
        exit 3
    fi

    echo_green "[+] Done"
}

function decrypt_file
{
    generate_password

    if [ -z "$1" ]; then
        echo $ENCRYPT_PASS | (gpg --batch --passphrase-fd 0 -d $GPG_PASSWORDS_FILE 2>> /dev/null || (echo_red '[-] Error: Wrong password') && exit -2) \
                            | sed 's/\t/    /'
    else
        echo $ENCRYPT_PASS | gpg --batch --passphrase-fd 0 -d $GPG_PASSWORDS_FILE 2>> /dev/null \
                            | sed 's/\t/    /' \
                            | grep '^[0-9/:]\+$' -v | grep ' \+\*' -v \
                            | grep "$1" -i --after-context=3
    fi

    if [ $? != 0 ]; then
        echo_red '[-] Error: Wrong password or no match'
        exit -2
    fi
}


if [ "$1" == "--help" ]; then
    echo "Usage: $0 [[OPTION] | [PATTERN]]"
    echo "    Without any parameter, the script will decrypt the password file and display it"
    echo "    if a PATTERN is given, only the relevant pattern will be printed"
    echo
    echo "OPTIONS:"
    echo "      --edit        decrypt and open the password file in the editor and re-encrypt it if edited"
    echo "      --help        display this help and exit"
    echo

elif [ "$1" == "--edit" ]; then
    edit_file
else
    decrypt_file "$1"
fi


