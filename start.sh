echo "Starting build process.."


cd /opt/$PROJECT/hugo
hugo_output=$(
    hugo \
    --verbose \
    2>&1
)
if [[ $(echo "$hugo_output" | grep -e "^ERROR:" | wc -l) -gt 0 ]]; then
    echo "Error building site:"
    echo "$hugo_output"
    exit 1
else
    echo "Site built."
fi;

echo "Starting hugo server.."
hugo server --bind 0.0.0.0
