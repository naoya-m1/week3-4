#!/usr/bin/env bash
echo "パスワードマネージャーへようこそ！"

while true; do

    read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" choice

    if [ "$choice" = "Add Password" ]; then
        read -p "サービス名を入力してください：" service
        read -p "ユーザー名を入力してください：" user
        read -p "パスワードを入力してください：" pass

        file_path=encrypted.txt.gpg

        if [ -e "$file_path" ]; then

            read -sp "復号化のためのパスフレーズを入力してください: " passphrase
            echo ""

            gpg --decrypt --batch --yes --passphrase "$passphrase" --output output_file.txt encrypted.txt.gpg
            echo -e "\n$service,$user,$pass," >> output_file.txt
            output="$output_file.txt"
            gpg --output encrypted.txt.gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback output_file.txt
            rm output_file.txt

        else
        read -sp "暗号化のためのパスフレーズを入力してください: " passphrase
        echo ""
        echo "$service,$user,$pass," | gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase "$passphrase" --output encrypted.txt.gpg

        echo "パスワードの追加は成功しました。"
        fi

    elif [ "$choice" = "Get Password" ]; then


        read -sp "復号化のためのパスフレーズを入力してください: " passphrase
        echo ""

        gpg --decrypt --batch --yes --passphrase "$passphrase" --output tmp.txt encrypted.txt.gpg



        read -p "サービス名を入力してください：" get_service
        entry=$(grep $get_service tmp.txt)
        if [ -z "$entry" ]; then
            echo "そのサービスは登録されていません。"
            #rm tmp.txt
        else
        echo "サービス名：$(echo "$entry" | cut -d ',' -f 1)"
        echo "ユーザー名：$(echo "$entry" | cut -d ',' -f 2)"
        echo "パスワード：$(echo "$entry" | cut -d ',' -f 3)"
        rm tmp.txt
        fi
    elif [ "$choice" = "Exit" ]; then
        echo "Thank you!"
        break
    else
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"

    fi
done
