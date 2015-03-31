# bash-pass
A Simple bash script to manage password with GPG encryption

# Getting started
First you need to edit the passwords file location, by changing the first two lines in the script
```bash
PASSWORDS_FILE="/home/`whoami`/Documents/passes.txt"
GPG_PASSWORDS_FILE="/home/`whoami`/Documents/passes.gpg"
```
`PASSWORDS_FILE` is a plain text file that contains your password, you can organize them any way you like, for example:
```
Google:
    USERNAME: XXXXXXX@gmail.com
    PASSWORD: XXXXXXXXXXXXXX
    OLD PASSWORD: XXXXXXX
    SECRET QUESTION: What is that thing? -> ANSWER

paypal.com:
    UN: XXXXXXX@gmail.com
    PW: XXXXXXXXXXXXXX

    QUESTION 1: What is whatever: XXXXXXX
    QUESTION 2: Who is whomever: XXXXXXX

Sourceforge:
    USERNAME: XXXXXXX
    PASSWORD: XXXXXXXXXXXXXX

Facebook:
    USERNAME: XXXXXXXXXX
    EMAIL: XXXXXXXXXXXXXX@gmail.com
    PASSWORD: XXXXXXXXXXXXXX

```
`GPG_PASSWORDS_FILE` is will be the encrypted password file with a symmetric cipher using a passphrase. feel free to edit it.

To edit your passwords or generate the encrypted file for the first time, run this script with --edit argument:
```bash
./pass.sh --edit
[*] Edit passwrods file: /home/user/Documents/passes.txt
[*] Please choose a password that will be used to encrypt the passwords file
[*] Note: File at /home/user/Documents/passes.txt will be deleted after encryption
[*] Password: 
[+] Start editing
[+] Encrypt new file: /home/user/Documents/passes.txt
[+] Delete decrypted file: /home/user/Documents/passes.txt
[+] Done
```

# View your passwords
To view your passwords, run this script without any argument, then it will print your password to the terminal.
```bash
./pass.sh
[*] Password:

Google:
    USERNAME: XXXXXXX@gmail.com
    PASSWORD: XXXXXXXXXXXXXX
    OLD PASSWORD: XXXXXXX
    SECRET QUESTION: What is that thing? -> ANSWER

paypal.com:
    UN: XXXXXXX@gmail.com
    PW: XXXXXXXXXXXXXX

    QUESTION 1: What is whatever: XXXXXXX
    QUESTION 2: Who is whomever: XXXXXXX
...
```

# Search
The best thing in this script is that you can access a specific password very quickly, just pass your search pattern as the first argument, and the script will print only the relevant password information:
```bash
./pass.sh paypal
[*] Password: 

paypal.com:
    UN: XXXXXXX@gmail.com
    PW: XXXXXXXXXXXXXX
```

# Add or change passwords
Add new password or change the existing one is simple, run this script with --edit argument, and it will decrypt your password file, launch `vim` and re-encrypt the passwords file if it was changed
```
./pass.sh --edit
[*] Edit encrypted file: /home/user/Documents/passes.gpg
[*] Password: 

[+] Decrypt file: /home/user/Documents/passes.gpg
[+] Start editing
<vim launched with your passwords file>
[+] Delete old encrypted file: /home/user/Documents/passes.gpg
«/home/user/Documents/passes.gpg» deleted
[+] Encrypt new file: /home/user/Documents/passes.txt
[+] Delete decrypted file: /home/user/Documents/passes.txt
[+] Done
```

That's all! hope you find it useful
