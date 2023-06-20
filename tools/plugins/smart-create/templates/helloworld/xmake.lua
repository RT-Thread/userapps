add_rules("mode.debug", "mode.release")

target("${TARGETNAME}")
do
    add_files("src/*.c")
end
target_end()

${FAQ}
