set_xmakever("2.7.2")
includes("packages/**.lua")
set_project("libnode-test")

set_languages("cxx20", "cxx2a")
set_runtimes(is_mode("debug") and "MTd" or "MT")
set_symbols("debug")

add_requires("libnode")
add_rules("plugin.vsxmake.autoupdate")

if is_os("windows") then
    add_toolchains("msvc")
end

target("libnode-test")
    set_default(true)
    set_kind("phony")
    add_packages("libnode")
    on_load(function (target)
        os.trycp(path.join(target:pkg("libnode"):installdir(), "bin"), "artifacts/")
        os.trycp(path.join(target:pkg("libnode"):installdir(), "node"), "artifacts/")
    end)