package("libnode")
    set_homepage("https://nodejs.org")
    set_license("MIT")

    add_urls("https://nodejs.org/dist/v$(version)/node-v$(version).tar.gz")
    add_versions("20.12.2", "bc57ee721a12cc8be55bb90b4a9a2f598aed5581d5199ec3bd171a4781bfecda")

    on_load("windows", function (package)
        package:add("deps", "nasm")
    end)

    on_install("macosx", "linux", "windows", function (package)
        io.replace("common.gypi", "'-fno-rtti',", "", { plain = true })
        io.replace("configure.py", "    shlib_suffix = 'so.%s'", "    shlib_suffix = 'so'", { plain = true })
        io.replace("tools/v8_gypfiles/features.gypi", "'v8_advanced_bigint_algorithms%%': 1", "'v8_advanced_bigint_algorithms%%': 1,\n    'use_rtti%%': 1")

        if package:is_plat("windows") then
            local configs = { is_mode("debug") and "debug" or "release", "x64", "dll", "no-cctest" }
            print(is_mode("debug") and "debug" or "release")
            os.vrunv("vcbuild.bat", configs)
        else
            local configs = { is_mode("debug") and "--debug" or "", "--shared", "--prefix=" .. package:installdir("rel") }
            os.vrunv("./configure", configs)
            os.vrunv("make", { "-j4" })
        end
        os.trycp("out/Release/*.so", package:installdir("bin"))
        os.trycp("out/Release/*.lib", package:installdir("lib"))
        os.trycp("out/Release/*.dll", package:installdir("bin"))
        os.trycp("out/Release/*.pdb", package:installdir("bin"))
        os.trycp("out/Debug/*.so", package:installdir("bin"))
        os.trycp("out/Debug/*.lib", package:installdir("lib"))
        os.trycp("out/Debug/*.dll", package:installdir("bin"))
        os.trycp("out/Debug/*.pdb", package:installdir("bin"))
        os.trycp("src/**.h", package:installdir("include"), { rootdir="src" })
        os.trycp("deps/openssl/**.h", package:installdir("deps", "openssl"), { rootdir="deps/openssl" })
        os.trycp("deps/uv/include/**.h", package:installdir("deps", "uv", "include"), { rootdir="deps/uv/include" })
        os.trycp("deps/v8/include/**.h", package:installdir("deps", "v8", "include"), { rootdir="deps/v8/include" })
        --package:add("includedirs", "include", "deps", "deps/openssl", "deps/uv", "deps/uv/include", "deps/v8", "deps/v8/include", {public = true})
    end)

    add_includedirs("include", "deps", "deps/openssl", "deps/uv", "deps/uv/include", "deps/v8", "deps/v8/include", {public = true})