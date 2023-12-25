#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

if ! command -v unzip &> /dev/null
then
    echo "unzip could not be found"
    echo "Installing unzip..."
    sudo apt-get install unzip
else
    echo "unzip is installed"
fi

# Run a query (dataset: samples, table: shakespeare, substring: raisin)

if (bq query --use_legacy_sql=false \
'SELECT
   word,
   SUM(word_count) AS count
 FROM
   `bigquery-public-data`.samples.shakespeare
 WHERE
   word LIKE "%raisin%"
 GROUP BY
   word')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Number of times substring "raisin" appeared: Checkpoint Completed (1/6)'

# Run a query (dataset: samples, table: shakespeare, substring: huzzah)

    if (bq query --use_legacy_sql=false \
    'SELECT
    word
    FROM
    `bigquery-public-data`.samples.shakespeare
    WHERE
    word = "huzzah"')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Number of times substring "huzzah" appeared: Checkpoint Completed (2/6)'

# Create a new dataset (name: babynames)

        if (bq mk babynames)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Dataset 'babynames' created: Checkpoint Completed (3/6)'

# Load the data into a new table

            if (curl -LO http://www.ssa.gov/OACT/babynames/names.zip &&\

            unzip names.zip &&\

            bq load babynames.names2010 yob2010.txt name:string,gender:string,count:integer)

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Loaded data into a dataset table: Checkpoint Completed (4/6)'

# Run queries against your dataset table

                if (bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'F' ORDER BY count DESC LIMIT 5" &&\

                bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'M' ORDER BY count ASC LIMIT 5")

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Run the Queries: Checkpoint Completed (5/6)'

# Remove the babynames dataset

                    printf "\n\e[1;31m%s\n\n\e[m" 'Do not proceed further without checking the Green Tick in "Task 4 & 5"'
                    while true; do
                        echo -n "Did you get a green tick? [Y/N]: "
                        read answer

                        if [ "$answer" = "${answer#[Yy]}" ] ;then
                            echo "You answered no. Re-running the previous commands..."
                            
                            # Load the data into a new table
                            if (curl -LO http://www.ssa.gov/OACT/babynames/names.zip &&\
                            unzip names.zip &&\
                            bq load babynames.names2010 yob2010.txt name:string,gender:string,count:integer)
                            then
                                printf "\n\e[1;96m%s\n\n\e[m" 'Loaded data into a dataset table: Checkpoint Completed (4/6)'
                            fi

                            # Run queries against your dataset table
                            if (bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'F' ORDER BY count DESC LIMIT 5" &&\
                            bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'M' ORDER BY count ASC LIMIT 5")
                            then
                                printf "\n\e[1;96m%s\n\n\e[m" 'Run the Queries: Checkpoint Completed (5/6)'
                            fi
                        else
                            echo "You answered yes. Removing dataset..."
                                        
                            if (echo "y" >  yes &&\

                            sleep 10 &&\

                            bq rm -r babynames < yes)

                            then
                                printf "\n\e[1;96m%s\n\n\e[m" 'Removed the babynames dataset: Checkpoint Completed (6/6)'
                            fi
                            break
                        fi
                    done
                fi
            fi
        fi
    fi
fi

gcloud auth revoke --all