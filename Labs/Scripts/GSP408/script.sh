#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Find the total number of customers went through checkout

if (bq query --nouse_legacy_sql \
'SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY hits_page_pageTitle' 

bq query --nouse_legacy_sql \
'SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_page_pageTitle = "Checkout Confirmation"
GROUP BY hits_page_pageTitle')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Total number of customers that went through checkout: Checkpoint Completed (1/3)'

# List the cities with the most transactions with your ecommerce site

    if (bq query --nouse_legacy_sql \
    'SELECT
    geoNetwork_city,
    SUM(totals_transactions) AS totals_transactions,
    COUNT( DISTINCT fullVisitorId) AS distinct_visitors
    FROM
    `data-to-insights.ecommerce.rev_transactions`
    GROUP BY geoNetwork_city' 

    bq query --nouse_legacy_sql \
    'SELECT
    geoNetwork_city,
    SUM(totals_transactions) AS totals_transactions,
    COUNT( DISTINCT fullVisitorId) AS distinct_visitors
    FROM
    `data-to-insights.ecommerce.rev_transactions`
    GROUP BY geoNetwork_city
    ORDER BY distinct_visitors DESC' 

    bq query --nouse_legacy_sql \
    'SELECT
    geoNetwork_city,
    SUM(totals_transactions) AS total_products_ordered,
    COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
    SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
    FROM
    `data-to-insights.ecommerce.rev_transactions`
    GROUP BY geoNetwork_city
    ORDER BY avg_products_ordered DESC' 

    bq query --nouse_legacy_sql \
    'SELECT
    geoNetwork_city,
    SUM(totals_transactions) AS total_products_ordered,
    COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
    SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
    FROM
    `data-to-insights.ecommerce.rev_transactions`
    GROUP BY geoNetwork_city
    HAVING avg_products_ordered > 20
    ORDER BY avg_products_ordered DESC')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Cities with the most transactions: Checkpoint Completed (2/3)'

# Find the total number of products in each product category

        if (bq query --nouse_legacy_sql \
        'SELECT
        COUNT(DISTINCT hits_product_v2ProductName) as number_of_products,
        hits_product_v2ProductCategory
        FROM `data-to-insights.ecommerce.rev_transactions`
        WHERE hits_product_v2ProductName IS NOT NULL
        GROUP BY hits_product_v2ProductCategory
        ORDER BY number_of_products DESC
        LIMIT 5')

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Total number of products: Checkpoint Completed (3/3)'
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all
