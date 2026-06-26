#!/bin/bash
set -e

echo "Γράψε μια περιγραφή για το commit (ή πάτα Enter για κενό):"
read user_message

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

current_branch=$(git branch --show-current)

if [ -z "$current_branch" ]; then
    echo "ΣΦΑΛΜΑ: Είσαι σε detached HEAD."
    echo "Πρώτα πήγαινε σε branch, π.χ.:"
    echo "git switch master"
    echo "ή:"
    echo "git switch -c main"
    exit 1
fi

git add .

dangerous_files=$(git diff --cached --name-only | grep -E '\.(pdf|zip|sqlite3|sqlite|db|o|so|exe|log|aux|out|toc|synctex\.gz)$' || true)

if [ -n "$dangerous_files" ]; then
    echo "ΠΡΟΣΟΧΗ: Πήγαν να μπουν στο commit αρχεία που συνήθως δεν πρέπει:"
    echo "$dangerous_files"
    echo
    echo "Ακύρωση. Βγάλε τα από staging ή διόρθωσε το .gitignore."
    echo "Παράδειγμα:"
    echo "git restore --staged path/to/file"
    exit 1
fi

if [[ -z $(git status --porcelain) ]]; then
    echo "Δεν υπάρχουν αλλαγές για commit."
    exit 0
fi

if [ -z "$user_message" ]; then
    final_message="Auto-commit: $timestamp"
else
    final_message="$user_message ($timestamp)"
fi

git commit -m "$final_message"
git push -u origin "$current_branch"
