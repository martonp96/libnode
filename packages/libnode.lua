package("libnode")
    set_homepage("https://nodejs.org")
    set_license("MIT")

    add_urls("https://nodejs.org/dist/v$(version)/node-v$(version).tar.gz")
    add_versions("20.12.2", "bc57ee721a12cc8be55bb90b4a9a2f598aed5581d5199ec3bd171a4781bfecda")

    on_load("windows", function (package)
        package:add("deps", "nasm")
    end)

    on_install("macosx", "linux", "windows", function (package)
        -- reenable internal module use
        io.replace("lib/internal/bootstrap/realm.js", "StringPrototypeStartsWith(id, 'internal/')", "StringPrototypeStartsWith(id, 'yespls/')", { plain = true })
        -- don't add version suffix to the so file
        io.replace("configure.py", "    shlib_suffix = 'so.%s'", "    shlib_suffix = 'so'", { plain = true })
        -- enable RTTI for the build
        io.replace("common.gypi", "'-fno-rtti',", "", { plain = true })
        io.replace("tools/v8_gypfiles/features.gypi", "'v8_advanced_bigint_algorithms%%': 1", "'v8_advanced_bigint_algorithms%%': 1,\n    'use_rtti%%': 1")
        -- rename output file name
        io.replace("node.gyp", "'libnode'", "'libnode20'", { plain = true })
        io.replace("tools/install.py", "libnode.", "libnode20.", { plain = true })
        io.replace("vcbuild.bat", "libnode.", "libnode20.", { plain = true })


        if package:is_plat("windows") then
            local configs = { is_mode("debug") and "debug" or "release", "x64", "dll", "no-cctest" }
            os.vrunv("vcbuild.bat", configs)
        else
            local configs = { "--shared", "--prefix=" .. package:installdir("rel") }
            if is_mode("debug") then
                table.insert(configs, "--debug")
            end
            os.vrunv("./configure", configs)
            os.vrunv("make", { "-j4" })
        end

        local type = is_mode("debug") and "Debug" or "Release"
        os.trycp("out/" .. type .. "/libnode20.so", package:installdir("bin"))
        os.trycp("out/" .. type .. "/libnode20.lib", package:installdir("bin"))
        os.trycp("out/" .. type .. "/libnode20.dll", package:installdir("bin"))
        os.trycp("out/" .. type .. "/libnode20.pdb", package:installdir("bin"))
        os.trycp("src/**.h", package:installdir("node"), { rootdir="src" })
        os.trycp("deps/openssl/**.h", package:installdir("node", "openssl"), { rootdir="deps/openssl" })
        os.trycp("deps/uv/include/**.h", package:installdir("node", "uv"), { rootdir="deps/uv/include" })
        os.trycp("deps/v8/include/**.h", package:installdir("node", "v8"), { rootdir="deps/v8/include" })
    end)

    add_includedirs("node", "node/openssl", "node/uv", "node/uv", "node/v8", {public = true})