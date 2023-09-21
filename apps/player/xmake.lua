add_rules("mode.debug", "mode.release")

add_requires("sdl2")
add_requires("sdl2_image")
add_requires("ffmpeg")

target("player")
do
    add_files("*.c")
    add_packages("sdl2")
    add_packages("sdl2_image")
    add_packages("ffmpeg")
end
target_end()
