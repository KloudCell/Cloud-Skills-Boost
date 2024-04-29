# **To be done using Google Cloud Shell**

**1. Check that Cloud Monitoring has been enabled**

**2. Check that the video queue length custom metric has been created**

**3. Check that a custom log based metric for large video upload rate has been created**

**4. Check that custom metrics for the video service have been added to the media dashboard**

**5. Check that an alert has been created for large video uploads**

- Get these values from `Login Credentials`

```
METRIC_NAME=
```
```
THRESHOLD_VAL=
```

```bash
ID=$(gcloud config list --format 'value(core.project)')
ZONE=$(gcloud compute instances list --filter="name=video-queue-monitor" --format "get(zone)" | awk -F/ '{print $NF}')
REGION=${ZONE::-2}
VIDEO_ID=$(gcloud compute instances describe video-queue-monitor --zone $ZONE --format="value(id)")

cat > start-up-script.sh <<EOF
#!/bin/bash

REGION=$REGION
ZONE=$ZONE
PROJECT_ID=$ID

## Install Golang
sudo apt update && sudo apt -y
sudo apt-get install wget -y
sudo apt-get -y install git
sudo chmod 777 /usr/local/
sudo wget https://go.dev/dl/go1.19.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.6.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install ops agent 
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo service google-cloud-ops-agent start

# Create go working directory and add go path
mkdir /work
mkdir /work/go
mkdir /work/go/cache
export GOPATH=/work/go
export GOCACHE=/work/go/cache

# Install Video queue Go source code
cd /work/go
mkdir video
gsutil cp gs://spls/gsp338/video_queue/main.go /work/go/video/main.go

# Get Cloud Monitoring (stackdriver) modules
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver

# Configure env vars for the Video Queue processing application
MY_PROJECT_ID=$ID
MY_GCE_INSTANCE_ID=$VIDEO_ID
MY_GCE_INSTANCE_ZONE=$ZONE

# Initialize and run the Go application
cd /work
go mod init go/video/main
go mod tidy
go run /work/go/video/main.go
EOF

gcloud compute instances remove-metadata video-queue-monitor --keys=startup-script --zone=$ZONE
gcloud compute instances add-metadata video-queue-monitor --metadata-from-file=startup-script=$(readlink -f start-up-script.sh) --zone=$ZONE

gcloud logging metrics create $METRIC_NAME --description="custome metric" --log-filter='textPayload=~"file_format\: ([4,8]K).*"'

gcloud compute instances stop video-queue-monitor --zone=$ZONE
gcloud compute instances start video-queue-monitor --zone=$ZONE

cat <<'EOF'> dashboard.json
{
  "displayName": "Media_Dashboard",
  "dashboardFilters": [],
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Execution times for video_processing [95TH PERCENTILE]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "breakdowns": [],
              "dimensions": [],
              "measures": [],
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_PERCENTILE_95",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_DELTA"
                  },
                  "filter": "metric.type=\"cloudfunctions.googleapis.com/function/execution_times\" resource.type=\"cloud_function\" resource.label.\"function_name\"=\"video_processing\""
                },
                "unitOverride": "ns"
              }
            }
          ],
          "thresholds": [],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        },

      },
      {
        "title": "Executions for video_processing",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "breakdowns": [],
              "dimensions": [],
              "measures": [],
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "filter": "metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" resource.type=\"cloud_function\" resource.label.\"function_name\"=\"video_processing\""
                },
                "unitOverride": "1"
              }
            }
          ],
          "thresholds": [],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        },

      },
      {
        "title": "Execution times [MEAN]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "breakdowns": [],
              "dimensions": [],
              "measures": [],
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_SUM"
                  },
                  "filter": "metric.type=\"cloudfunctions.googleapis.com/function/execution_times\" resource.type=\"cloud_function\""
                },
                "unitOverride": "ns"
              }
            }
          ],
          "thresholds": [],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        },
      },
      {
        "title": "OpenCensus/my.videoservice.org/measure/input_queue_size (filtered) [SUM]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "breakdowns": [],
              "dimensions": [],
              "measures": [],
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_MEAN"
                  },
                  "filter": "metric.type=\"custom.googleapis.com/opencensus/my.videoservice.org/measure/input_queue_size\" resource.type=\"gce_instance\" resource.label.\"instance_id\"=\"VIDEO_ID\""
                }
              }
            }
          ],
          "thresholds": [],
          "yAxis": {
            "label": "",
            "scale": "LINEAR"
          }
        },

      },
      {
        "title": "logging/user/METRIC_NAME [SUM]",
        "xyChart": {
          "chartOptions": {
            "mode": "COLOR"
          },
          "dataSets": [
            {
              "breakdowns": [],
              "dimensions": [],
              "measures": [],
              "minAlignmentPeriod": "60s",
              "plotType": "LINE",
              "targetAxis": "Y1",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [],
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "filter": "metric.type=\"logging.googleapis.com/user/METRIC_NAME\" resource.type=\"gce_instance\""
                }
              }
            }
          ],
          "thresholds": [],
          "yAxis": {
            "label": "",
            "scale": "LINEAR"
          }
        },

      }
    ]
  }
}
EOF

sed  -i "s/METRIC_NAME/${METRIC_NAME}/g" dashboard.json
sed -i "s/VIDEO_ID/${ID}/g" dashboard.json

gcloud monitoring dashboards create --config-from-file=dashboard.json

cat <<'EOF'> alert.json
{
  "displayName": "kloudcell",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - logging/user/METRIC_NAME",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/METRIC_NAME\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": <THRESHOLD_VAL>
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "604800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF

sed  -i "s/METRIC_NAME/${METRIC_NAME}/g" alert.json
sed -i "s/<THRESHOLD_VAL>/${THRESHOLD_VAL}/g" alert.json

gcloud alpha monitoring policies create --policy-from-file="alert.json"
```
## Lab Completed🎉