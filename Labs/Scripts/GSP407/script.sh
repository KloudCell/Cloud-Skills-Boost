#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Identify duplicate rows

if (bq query --use_legacy_sql=false '#standardSQL
SELECT COUNT(*) as num_duplicate_rows, * FROM
`data-to-insights.ecommerce.all_sessions_raw`
GROUP BY
fullVisitorId, channelGrouping, time, country, city, totalTransactionRevenue, transactions, timeOnSite, pageviews, sessionQualityDim, date, visitId, type, productRefundAmount, productQuantity, productPrice, productRevenue, productSKU, v2ProductName, v2ProductCategory, productVariant, currencyCode, itemQuantity, itemRevenue, transactionRevenue, transactionId, pageTitle, searchKeyword, pagePathLevel1, eCommerceAction_type, eCommerceAction_step, eCommerceAction_option
HAVING num_duplicate_rows > 1;')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Duplicate Rows: Checkpoint Completed (1/2)'

# Write basic SQL on ecommerce data

    if (bq query --use_legacy_sql=false '
    SELECT
    COUNT(*) AS product_views,
    COUNT(DISTINCT fullVisitorId) AS unique_visitors
    FROM `data-to-insights.ecommerce.all_sessions`;'

    bq query --use_legacy_sql=false '
    SELECT
    COUNT(DISTINCT fullVisitorId) AS unique_visitors,
    channelGrouping
    FROM `data-to-insights.ecommerce.all_sessions`
    GROUP BY channelGrouping
    ORDER BY channelGrouping DESC;'

    bq query --use_legacy_sql=false '
    SELECT
    (v2ProductName) AS ProductName
    FROM `data-to-insights.ecommerce.all_sessions`
    GROUP BY ProductName
    ORDER BY ProductName;'

    bq query --use_legacy_sql=false '
    SELECT
    COUNT(*) AS product_views,
    (v2ProductName) AS ProductName
    FROM `data-to-insights.ecommerce.all_sessions`
    WHERE type = "PAGE"
    GROUP BY v2ProductName
    ORDER BY product_views DESC
    LIMIT 5;'

    bq query --use_legacy_sql=false '
    WITH unique_product_views_by_person AS (
    SELECT
    fullVisitorId,
    (v2ProductName) AS ProductName
    FROM `data-to-insights.ecommerce.all_sessions`
    WHERE type = "PAGE"
    GROUP BY fullVisitorId, v2ProductName )
    SELECT
    COUNT(*) AS unique_view_count,
    ProductName
    FROM unique_product_views_by_person
    GROUP BY ProductName
    ORDER BY unique_view_count DESC
    LIMIT 5;'

    bq query --use_legacy_sql=false '
    SELECT
    COUNT(*) AS product_views,
    COUNT(productQuantity) AS orders,
    SUM(productQuantity) AS quantity_product_ordered,
    v2ProductName
    FROM `data-to-insights.ecommerce.all_sessions`
    WHERE type = "PAGE"
    GROUP BY v2ProductName
    ORDER BY product_views DESC
    LIMIT 5;'

    bq query --use_legacy_sql=false '
    SELECT
    COUNT(*) AS product_views,
    COUNT(productQuantity) AS orders,
    SUM(productQuantity) AS quantity_product_ordered,
    SUM(productQuantity) / COUNT(productQuantity) AS avg_per_order,
    (v2ProductName) AS ProductName
    FROM `data-to-insights.ecommerce.all_sessions`
    WHERE type = "PAGE"
    GROUP BY v2ProductName
    ORDER BY product_views DESC
    LIMIT 5;')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Basic SQL on ecommerce data: Checkpoint Completed (2/2)'
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all