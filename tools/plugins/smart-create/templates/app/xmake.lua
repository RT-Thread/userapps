add_rules("mode.debug", "mode.release")

add_requires("busybox")

target("${TARGETNAME}")
do
    set_kind("phony")
    add_packages("busybox")
end
target_end()
