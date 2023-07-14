package("lnx-headers")
do
    set_description("The headers for linux compatibility")

    on_install(function(package)
        os.vcp(path.join(os.scriptdir(), "inc/linux/*"), package:installdir("include/linux"))
    end)

    on_test(function(package)
        assert(package:has_cincludes("linux/if_packet.h"))
    end)
end
