
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
Effects, such as storage, network, user, should be separated for different software.
So this is my argument to prefer `podman` over NixOS containers, because I am a chaotic effect,
so I cannot declare the definition of containers upfront.

## In practice - usage
Did you have problem like the followings:

 -  a software dump its caches in the user home, for instance `cargo` creates `~/.cargo` directory,
    gradle creates `~/.gradle` direcoty,
    where by design they don't keep the caches of different projects separated,
    so it's hard to clean up their mess after finish working on a project for just 2 hours.
 -  Another class of problem is that you download a software and it'll reside in `/nix/store`
    for months, where you just needed that software for an hour to be there.
    For instance, I want to work with my project in Latex,
    and now it stays there when I don't need that.
 -  Or worse, a project that has CUDA dependencies so you have to add
    CUDA cache substituter to the dependencies of the entire NixOS.
 -  You can solve above problems by using containers, of course,
    but you cannot wire up home-manager's configurations into the containers easily.

You can isolate their effect by creating containers and removing them after finishing your work.
Additionally, you can wire home-manager's configurations into the containers.
This project can help you with such a task.

Checkout [development pod](https://github.com/hadilq/nix-effect-pod/tree/main/development),
and [librewolf pod](https://github.com/hadilq/nix-effect-pod/tree/main/librewolf).

Also, I am using it in [my configuration](https://github.com/hadilq/nix-home-manager-config),
so there would be some examples and usages.

# Contribution
I wish the code was more concrete, but I admit it's a bit hacky!
If you know how to fix them,
feel free to create issues, and pull requests.

