#!/bin/bash

echo "please ensure that your maven settings.xml has the suitable username and password for S3 "
sleep 1

# path of the main folder
PATH_OF_MAIN_FOLDER=`pwd`

CASE_7514=""
CASE_STOCK_DEMO_FINAL=""

deploy(){

PATH_TO_DEPLOED_FOLDER=$PWD

echo "PATH_TO_DEPLOED_FOLDER=$PATH_TO_DEPLOED_FOLDER"

# search for jar/zip/war file in folder
JAR_FILE=$PATH_TO_DEPLOED_FOLDER/`ls *.jar`
if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE=$PATH_TO_DEPLOED_FOLDER/`ls *.zip`
fi

if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE=$PATH_TO_DEPLOED_FOLDER/`ls *.war`
fi

# search for pom/xml file in folder
POM_FILE=$PATH_TO_DEPLOED_FOLDER/`ls *.xml`

if [ ! -f "$POM_FILE" ]; then
    POM_FILE=$PATH_TO_DEPLOED_FOLDER/`ls *.pom`
fi

echo "pwd=$PWD"
echo "JAR_FILE=$JAR_FILE"
echo "POM_FILE=$POM_FILE"

if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE="$PATH_TO_DEPLOED_FOLDER/$JAR_FILE"
    if [ ! -f "$JAR_FILE" ]; then
        echo "Jar file does not exist"
        exit 1
    fi
fi

if [ ! -f "$POM_FILE" ]; then
    POM_FILE="$PATH_TO_DEPLOED_FOLDER/$POM_FILE"
    if [ ! -f "$POM_FILE" ]; then
        echo "pom file does not exist"
        exit 1
    fi
fi

# run script from folder with correct pom
cd $PATH_OF_MAIN_FOLDER/notToUploadDir
mvn deploy:deploy-file "-Durl=s3://gigaspaces-maven-repository-eu" "-DrepositoryId=org.openspaces" "-Dfile=$JAR_FILE" "-DpomFile=$POM_FILE"
cd -

}

for folder in $PATH_OF_MAIN_FOLDER/*;
  do 
    echo "folder=$folder"

    # handle folder with sub-directories
    if [ "$folder" == "$PATH_OF_MAIN_FOLDER/case7514" ]
    then
        CASE_7514=$PATH_OF_MAIN_FOLDER/case7514
        echo "set CASE_7514=$CASE_7514"
#        echo "working on case7514 folder"
#        for folder_in_case_7514 in $PATH_OF_MAIN_FOLDER/case7514/*;
#            do
#            [ -d $folder_in_case_7514 ] && cd "$folder_in_case_7514" && deploy
#            cd -
#        done
#        echo "done working on case 7514"

    elif [ "$folder" == "$PATH_OF_MAIN_FOLDER/StockDemoFinal" ]
        then

        CASE_STOCK_DEMO_FINAL=$PATH_OF_MAIN_FOLDER/StockDemoFinal
        echo "set CASE_STOCK_DEMO_FINAL=$CASE_STOCK_DEMO_FINAL"
#        echo "working on StockDemoFinal folder"
#        for folder_in_stock_demo in $PATH_OF_MAIN_FOLDER/StockDemoFinal/*;
#            do
#                [ -d $folder_in_stock_demo ] && cd "$folder_in_stock_demo" && deploy
#                cd -
#        done

    # not to upload folder
    elif [ "$folder" == "$PATH_OF_MAIN_FOLDER/notToUploadDir" ]
    	then
    	echo "skip notToUploadDir"
    	# ignore - this folder only created to make the script run with the currect pom

    # regular folder
    else
     [ -d $folder ] && cd "$folder" && deploy
     cd ..
    fi
 done;

 echo "working on $CASE_7514/v1/"
 for folder in $CASE_7514/v1/*;
    do
     [ -d $folder ] && cd "$folder" && deploy
     cd ..
 done

echo "working on $CASE_7514/v2/"
 for folder in $CASE_7514/v2/*;
    do
     [ -d $folder ] && cd "$folder" && deploy
     cd ..
 done

 echo "working on $CASE_STOCK_DEMO_FINAL"
 for folder in $CASE_STOCK_DEMO_FINAL/*;
    do
     [ -d $folder ] && cd "$folder" && deploy
     cd ..
 done


echo "uploading main pom"
MAIN_POM_PATH=${PATH_OF_MAIN_FOLDER}/pom.xml
cd $PATH_OF_MAIN_FOLDER/notToUploadDir
mvn deploy:deploy-file "-Durl=s3://gigaspaces-maven-repository-eu" "-DrepositoryId=org.openspaces" "-Dfile=$MAIN_POM_PATH" "-DpomFile=$MAIN_POM_PATH"
cd -

echo "##### FINISH to upload to s3 !!! #####"