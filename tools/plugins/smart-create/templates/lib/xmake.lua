add_rules("mode.debug", "mode.release")

add_requires("${PACKAGE}")

target("${TARGETNAME}")
do
    add_files("*.c")
    add_packages("${PACKAGE}")
end
target_end()

${FAQ}
