#!/bin/bash
# @file generate-from-bash.sh
# @brief Generate Asciidoc contents from bash scripts.
#
# @description This script generated docs for all bash scripts of the respective repository and
# organizes them inside an Antora module.
#
# The script is called from ``entrypoint.sh``.
#
# IMPORTANT: Do not run this script directly! This script is intended to run as part of a Github
# Actions job!
#
# ==== Arguments
#
# The script does not accept any parameters.


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


ANTORA_YML="docs/antora.yml"
export ANTORA_MODULE_NAME="AUTO-GENERATED"
export ANTORA_MODULE="docs/modules/$ANTORA_MODULE_NAME"
export CONTENT_FOLDER="bash-docs"



# @description Generate a dedicated documentation file for a given script and save file inside the 
# Antora module.
#
# @example
#    echo "test: $(generateDocs path/to/some/script.sh)"
#
# @arg $1 String Path to bash script (mandatory)
#
# @exitcode 8 If path to bash script is missing
function generateDocs() {
  if [ -z "$1" ]; then
    echo -e "$LOG_ERROR Param missing: Path to bash script"
    echo -e "$LOG_ERROR exit" && exit 8
  fi

  SH_FILE="${1#"$(pwd)/"}" # clear path from $1
  SH_FILENAME="${SH_FILE##*/}"

  old=".sh"
  new="-sh"
  DOCS_FILE_PATTERN="${SH_FILE/"$old"/"$new"}" # change .sh to -sh

  ADOC_FILE="$DOCS_FILE_PATTERN.adoc"
  MD_FILE="$DOCS_FILE_PATTERN.md"
  TMP_FILE="$DOCS_FILE_PATTERN.md.adoc"

  DOCS_PATH=${DOCS_FILE_PATTERN%/*}
  if [ "$DOCS_PATH" = "$DOCS_FILE_PATTERN" ]; then
    DOCS_PATH=""
  fi

  echo "[INFO] [Step 1/6] Create directory $ANTORA_MODULE/pages/$CONTENT_FOLDER/$DOCS_PATH"
  mkdir -p "$ANTORA_MODULE/pages/$CONTENT_FOLDER/$DOCS_PATH"
  
  echo "[INFO] [Step 2/6] Generate '$ANTORA_MODULE/pages/$CONTENT_FOLDER/$MD_FILE' from '$SH_FILE"
  shdoc < "$SH_FILE" > "$ANTORA_MODULE/pages/$CONTENT_FOLDER/$MD_FILE"

  echo "[INFO] [Step 3/6] Convert markdown to asciidoc"
  source="$ANTORA_MODULE/pages/$CONTENT_FOLDER/$MD_FILE"
  target="$ANTORA_MODULE/pages/$CONTENT_FOLDER/$TMP_FILE"
  kramdoc -o "$target" "$source"
  rm "$source"

  echo "[INFO] [Step 4/6] Remove first line from temp-adoc $target"
  sed -i '1d' "$target"

  echo "[INFO] [Step 5/6] Create $ANTORA_MODULE/pages/$CONTENT_FOLDER/$ADOC_FILE"
  echo "= $SH_FILENAME" > "$ANTORA_MODULE/pages/$CONTENT_FOLDER/$ADOC_FILE"
  (
    echo
    echo "// +-----------------------------------------------+"
    echo "// |                                               |"
    echo "// |    DO NOT EDIT HERE !!!!!                     |"
    echo "// |                                               |"
    echo "// |    File is auto-generated by pipline.         |"
    echo "// |    Contents are based on bash script docs.    |"
    echo "// |                                               |"
    echo "// +-----------------------------------------------+"
    echo

    cat "$target"
  ) >> "$ANTORA_MODULE/pages/$CONTENT_FOLDER/$ADOC_FILE"

  echo "[INFO] [Step 6/6] Remove temporary adoc file $target"
  rm "$target"

  echo "[DONE] Generated $ANTORA_MODULE/pages/$CONTENT_FOLDER/$ADOC_FILE"
}
export -f generateDocs


# @description Generate nav.adoc file for Antora module.
#
# @example
#    echo "test: $(generateNav)"
function generateNav() {
  echo "[INFO] Generate nav.adoc partial for bash scripts"
  touch "$ANTORA_MODULE/partials/$CONTENT_FOLDER/nav.adoc"
  
  (
    cd "$ANTORA_MODULE/pages/$CONTENT_FOLDER" || exit

    find "." -name '*-sh.adoc' -print0 | while IFS= read -r -d '' file
    do
      file="${file#./}"
      echo "* xref:$ANTORA_MODULE_NAME:$CONTENT_FOLDER/${file}[${file}]" >> "../../partials/$CONTENT_FOLDER/nav.adoc"
    done
  )

  echo "[INFO] Generate nav.adoc"
  echo "* xref:$ANTORA_MODULE_NAME:$CONTENT_FOLDER/index.adoc[]" > "$ANTORA_MODULE/nav.adoc"
  # echo "include::$ANTORA_MODULE_NAME:partial\$/$CONTENT_FOLDER/bash-docs/nav.adoc[]" >> "$ANTORA_MODULE/nav.adoc"

  echo "[INFO] Generate index.adoc"
  cp /tmp/index-template.adoc "$ANTORA_MODULE/pages/$CONTENT_FOLDER/index.adoc"
  # echo "= Bash Script Docs" > "$ANTORA_MODULE/pages/$CONTENT_FOLDER/index.adoc"
  (
    echo
    echo "include::$ANTORA_MODULE_NAME:partial\$/$CONTENT_FOLDER/nav.adoc[]"
  ) >> "$ANTORA_MODULE/pages/$CONTENT_FOLDER/index.adoc"
}


echo "[INFO] Version" && shdoc --version
echo "[INFO] Contents of current dir '$(pwd)'" && ls -alF
echo "[INFO] whoami = $(whoami)"

echo "[INFO] Initialize directory structure"
rm -rf "$ANTORA_MODULE"
mkdir "$ANTORA_MODULE"
mkdir "$ANTORA_MODULE/pages"
mkdir "$ANTORA_MODULE/pages/$CONTENT_FOLDER"
mkdir "$ANTORA_MODULE/partials"
mkdir "$ANTORA_MODULE/partials/$CONTENT_FOLDER"


echo "[INFO] Find all *.sh files and generate docs"
find "$(pwd)" -type f -name "*.sh" -exec bash -c 'generateDocs "$0"' {} \;

generateNav

echo "[INFO] Add module to antora.yml"
line="  - modules/$ANTORA_MODULE_NAME/nav.adoc"
grep -qxF "$line" "$ANTORA_YML" || echo "$line" >> "$ANTORA_YML"
