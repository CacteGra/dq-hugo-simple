racine@dqc-17:~/hugging$ cat ../reyes/update.sh 
#!/bin/sh

cd hugo/themes/hugo-noir
git add .
git commit -m "$1"
git push origin main
cd ../../../
git add .
git commit -m "$1"
git push origin master
