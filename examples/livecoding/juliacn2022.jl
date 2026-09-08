# This is a living coding for the JuliaCN 2022 meetup tutorial

############## Julia's package management #################
using Pkg

# the following code
Pkg.status()

# adding a package, which is equivalent to typing `] add Mods`.
pkg"add Mods"

# loading a package
using Mods

pathof(Mods)

# develop a package is different from adding a package.
pkg"dev https://github.com/scheinerman/Mods.jl.git"
 
pathof(Mods)