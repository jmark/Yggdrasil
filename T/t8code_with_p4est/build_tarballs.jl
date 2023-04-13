# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "t8code_with_p4est"
version = v"0.0.1"

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://github.com/DLR-AMR/t8code/releases/download/v1.1.2/t8code_v1.1.2_dirty.tar.gz", "63c1f157a833607b14bbad2c65909fa7e3bca20a94ad8a42ccb2abc8ed428553")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd t8code/
export CFLAGS="-O3 -std=c99"
export CXXFLAGS="-O3 -std=c++11"
export CC="mpicc"
export CXX="mpicxx"
mpiopts="--enable-mpi"
./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} --disable-static --without-blas --with-sc=/workspace/destdir --with-p4est=/workspace/destdir ${mpiopts}
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("i686", "linux"; libc = "glibc"),
    Platform("x86_64", "linux"; libc = "glibc"),
    Platform("aarch64", "linux"; libc = "glibc"),
    Platform("armv6l", "linux"; call_abi = "eabihf", libc = "glibc"),
    Platform("armv7l", "linux"; call_abi = "eabihf", libc = "glibc"),
    Platform("powerpc64le", "linux"; libc = "glibc"),
    Platform("i686", "linux"; libc = "musl"),
    Platform("x86_64", "linux"; libc = "musl"),
    Platform("aarch64", "linux"; libc = "musl"),
    Platform("armv6l", "linux"; call_abi = "eabihf", libc = "musl"),
    Platform("armv7l", "linux"; call_abi = "eabihf", libc = "musl")
]


# The products that we will ensure are always built
products = [
    LibraryProduct("libt8", :libt8)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="P4est_jll", uuid="6b5a15aa-cf52-5330-8376-5e5d90283449"))
    Dependency(PackageSpec(name="MPICH_jll", uuid="7cb0a576-ebde-5e09-9194-50597f1243b4"))
    Dependency(PackageSpec(name="Zlib_jll", uuid="83775a58-1f1d-513f-b197-d71354ab007a"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
