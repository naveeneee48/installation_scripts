#!/bin/bash
GITLAB_TOKEN="<gitlab-access-token>"
GITLAB_GROUP="<gitlab-group-name>"
GITLAB_API="https://gitlab.com/api/v4"
BASE_OUTPUT_DIR="./trufflehog-reports"
mkdir -p "$BASE_OUTPUT_DIR"
# Fetch all projects in the group
curl --silent --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_API/groups/$GITLAB_GROUP/projects?per_page=100" |
jq -r '.[].path_with_namespace' |
while read -r full_path; do
    project_name=$(basename "$full_path")
    group_name=$(dirname "$full_path")
    # Create subfolder for group
    GROUP_OUTPUT_DIR="$BASE_OUTPUT_DIR/$group_name"
    mkdir -p "$GROUP_OUTPUT_DIR"
    echo ":rocket: Scanning $full_path"
    repo_url="https://git:$GITLAB_TOKEN@gitlab.com/$full_path.git"
    json_output="$GROUP_OUTPUT_DIR/${project_name}.json"
    html_output="$GROUP_OUTPUT_DIR/${project_name}.html"
    # Run TruffleHog
    trufflehog --regex --entropy=True --json "$repo_url" > "$json_output"
    echo ":receipt: Converting JSON to HTML..."
    # Convert to HTML using embedded Python
    python3 - <<EOF
import json
from json2html import *
html_parts = []
with open("$json_output", "r") as f:
    for line in f:
        try:
            data = json.loads(line)
            html_parts.append(json2html.convert(json=data))
        except json.JSONDecodeError as e:
            print(f"Skipping line due to JSON error: {e}")
html_output = "<html><body>" + "<hr>".join(html_parts) + "</body></html>"
with open("$html_output", "w") as f:
    f.write(html_output)
EOF
    echo ":white_check_mark: Done: $html_output"
done
