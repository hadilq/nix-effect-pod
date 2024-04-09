
# Nix Effect Pod

I just created this `pod.nix` file based on available resouces in the Internet.
No guarantee that it's working!

## In theory

NixOS is built on pure functions.
Pure functions are functions that only one output is possible for a certain input.
This is the secret to reproducibility, and scalability.
But the world is big and our software wants to communicate with that,
so it cannot stay pure, therefore, effects exist.

The goal of this implementation is to modularize the effects, so keep us in-control.
Effects, such as storage, network, user, should be seperated for different softwares.
So this is my argument to prefer `podman` over NixOS containers, because I am a chaotic effect,
so I cannot declare the definition of containers upfront.

## In practice - usage
I am using it as [my configuration](https://github.com/hadilq/nix-home-manager-config),
so that would be some examples and how to use.

# Known problems
There are some FIXME in the code that I have no clue how to solve them!
Also the `nix-daemond` is not getting run in the `endpoint.sh`. So it may need more investigation.

# Contribution

I wish the code was more concrete, but I admit it's a bit hacky!
If you know how to fix them,
feel free to create issues, and pull requests.

