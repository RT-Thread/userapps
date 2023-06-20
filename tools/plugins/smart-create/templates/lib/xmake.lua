add_rules("mode.debug", "mode.release")

add_requires("zlib")

target("${TARGETNAME}")
do
    add_files("*.c")
    add_packages("zlib")
end
target_end()

${FAQ}
