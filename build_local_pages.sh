#!/bin/zsh
set -eu

REPO="/Users/nakada/zaiene_dev/ohara-lab-su"
DOCS="$REPO/docs"

cd "$REPO"

# Gemfile が無ければ作る（GitHub Pages と同じ環境）
if [ ! -f Gemfile ]; then
cat <<'EOF' > Gemfile
source "https://rubygems.org"
gem "github-pages", group: :jekyll_plugins
EOF
fi

# 必要な gem を取得
bundle install

# docs をソースにして Jekyll を起動
bundle exec jekyll serve \
  --source "$DOCS" \
  --destination "$DOCS/_site" \
  --livereload