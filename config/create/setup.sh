# Due to overwriting some files, do this step manually

cp config/create/forge*installer.jar .

java -jar forge*installer.jar --installServer

# These files needed are already in config/ and will be copied to root at container start
rm forge*installer.jar
rm ./run.* user_jvm_args.txt
