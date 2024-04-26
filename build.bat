cd node

git apply --reject --whitespace=fix ../patches/enable_rtti.patch
git apply --reject --whitespace=fix ../patches/internal_modules.patch
git apply --reject --whitespace=fix ../patches/rename_output.patch
git apply --reject --whitespace=fix ../patches/version_suffix.patch

vcbuild.bat release x64 dll no-cctest