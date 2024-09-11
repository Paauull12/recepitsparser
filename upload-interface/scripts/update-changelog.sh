#!/usr/bin/env bash

# Outputs the project property

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

CHANGELOG_FILE="CHANGELOG.md"
CHANGELOG_PATH="$ROOT_DIR/$CHANGELOG_FILE"

echo "# Changelog" > "$CHANGELOG_PATH"
echo "" >> "$CHANGELOG_PATH"

BRANCH_NAME=$("$ROOT_DIR/$PROJECT/scripts/git-branch-name.sh")
if [[ "${BRANCH_NAME%%/*}" == "release" ]]; then
    VERSION=${BRANCH_NAME#*/}
elif [[ "${BRANCH_NAME%%/*}" == "hotfix" ]]; then
    VERSION=${BRANCH_NAME#*/}
else
    VERSION="Next version"
fi

echo "## ${VERSION}" >> "$CHANGELOG_PATH"
echo "" >> "$CHANGELOG_PATH"

while read -r COMMIT ; do
    if [[ "${COMMIT}" == *"'feature/"* ]]; then
        echo "- ✨ ${COMMIT}" >> "$CHANGELOG_PATH"
    elif [[ "${COMMIT}" == *"'bugfix/"* ]]; then
        echo "- 🐞 ${COMMIT}" >> "$CHANGELOG_PATH"
    elif [[ "${COMMIT}" == *"'hotfix/"* ]]; then
        VERSION=$(echo "${COMMIT}" | sed -r "s/.*hotfix\/([^']*)'.*/\1/")
        {
            echo ""
            echo "## ${VERSION}"
            echo ""
        } >> "$CHANGELOG_PATH"
    elif [[ "${COMMIT}" == *"'release/"* ]]; then
        VERSION=$(echo "${COMMIT}" | sed -r "s/.*release\/([^']*)'.*/\1/")
        {
            echo ""
            echo "## ${VERSION}"
            echo ""
        } >> "$CHANGELOG_PATH"
    fi
done <<< "$(git -C "$ROOT_DIR" log --pretty="format:%h %ad %s [%an]" --date=format:"%Y-%m-%d %H:%M:%S")"

git -C "$ROOT_DIR" add "$CHANGELOG_FILE" || exit 1
git -C "$ROOT_DIR" commit -m "chore: update changelog" || echo "Cannot commit changelog"
