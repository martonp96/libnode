cd node

git --version

git apply --reject --whitespace=fix --directory=node ../patches/enable_rtti.patch
git apply --reject --whitespace=fix --directory=node ../patches/internal_modules.patch
git apply --reject --whitespace=fix --directory=node ../patches/rename_output.patch
git apply --reject --whitespace=fix --directory=node ../patches/version_suffix.patch

call vcbuild.bat release x64 dll no-cctest