# A fork of https://github.com/NixOS/nix/blob/82f6fba0d46985c6bf435d7ca0cdfd28746bf052/docker.nix
{
  system,
  nixEffectSource,
  pkgsSource,
  homeManagerSource,
  name ? "nix",
  nixosConfigurationSource,
  etcActivation ? false,
  homeActivation ? false,
  channelsList ? [ ],
  extraSubstituters ? [ ],
  extraTrustedPublicKeys ? [ ],
  nixpkgs ? (
    let
      eval = import "${pkgsSource}/nixos/lib/eval-config.nix" {
        inherit system;
        modules = [ (import nixosConfigurationSource) ];
        specialArgs = { inherit nixEffectSource pkgsSource homeManagerSource; };
      };
    in
    {
      inherit (eval) pkgs config options;
      system = eval.config.system.build.toplevel;
      inherit (eval.config.system.build) vm vmWithBootLoader;
    }
  ),
  pkgs ? nixpkgs.pkgs,
  lib ? pkgs.lib,
  tag ? "latest",
  bundleNixpkgs ? true,
  extraPkgs ? [ ],
  maxLayers ? 100,
  nixConf ? { },
  flake-registry ? (pkgs.formats.json { }).generate "flake-registry.json" {
    version = 2;
    flakes = pkgs.lib.mapAttrsToList (n: v: { inherit (v) from to exact; }) ({
      nixos = {
        from = {
          type = "indirect";
          id = "nixos";
        };
        to = pkgs.path;
        exact = true;
      };
      nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        to = pkgs.path;
        exact = true;
      };
    });
  },
  uid ? 1000,
  gid ? 1000,
  uname ? "dev",
  gname ? "dev",
  mountingDir ? "",
  userHome ? (
    lib.optionalAttrs (lib.length mountingDir != 0) (
      lib.warn "mountingDir argument is deprecated and will be removed." "/home/dev"
    )
  ),

}:
let
  defaultPkgs =
    with pkgs;
    [
      nix
      bashInteractive
      coreutils-full
      gnutar
      gzip
      gnugrep
      which
      curl
      less
      wget
      man
      cacert.out
      findutils
      iana-etc
      git
      openssh
      nixpkgs.config.system.path
    ]
    ++ extraPkgs;

  users = {

    root = {
      uid = 0;
      shell = "${pkgs.bashInteractive}/bin/bash";
      home = "/root";
      gid = 0;
      groups = [ "root" ];
      description = "System administrator";
    };

    nobody = {
      uid = 65534;
      shell = "${pkgs.shadow}/bin/nologin";
      home = "/var/empty";
      gid = 65534;
      groups = [ "nobody" ];
      description = "Unprivileged account (don't use!)";
    };

  }
  // lib.optionalAttrs (uid != 0) {
    "${uname}" = {
      uid = uid;
      shell = "${pkgs.bashInteractive}/bin/bash";
      home = "/home/${uname}";
      gid = gid;
      groups = [ "${gname}" ];
      description = "Nix user";
    };
  }
  // lib.listToAttrs (
    map (n: {
      name = "nixbld${toString n}";
      value = {
        uid = 30000 + n;
        gid = 30000;
        groups = [ "nixbld" ];
        description = "Nix build user ${toString n}";
      };
    }) (lib.lists.range 1 32)
  );

  groups = {
    root.gid = 0;
    nixbld.gid = 30000;
    nobody.gid = 65534;
  }
  // lib.optionalAttrs (gid != 0) {
    "${gname}".gid = gid;
  };

  userToPasswd = (
    k:
    {
      uid,
      gid ? 65534,
      home ? "/var/empty",
      description ? "",
      shell ? "/bin/false",
      groups ? [ ],
    }:
    "${k}:x:${toString uid}:${toString gid}:${description}:${home}:${shell}"
  );
  passwdContents = (lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs userToPasswd users)));

  userToShadow = k: { ... }: "${k}:!:1::::::";
  shadowContents = (lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs userToShadow users)));

  # Map groups to members
  # {
  #   group = [ "user1" "user2" ];
  # }
  groupMemberMap = (
    let
      # Create a flat list of user/group mappings
      mappings = (
        builtins.foldl' (
          acc: user:
          let
            groups = users.${user}.groups or [ ];
          in
          acc
          ++ map (group: {
            inherit user group;
          }) groups
        ) [ ] (lib.attrNames users)
      );
    in
    (builtins.foldl' (
      acc: v:
      acc
      // {
        ${v.group} = acc.${v.group} or [ ] ++ [ v.user ];
      }
    ) { } mappings)
  );

  groupToGroup =
    k:
    { gid }:
    let
      members = groupMemberMap.${k} or [ ];
    in
    "${k}:x:${toString gid}:${lib.concatStringsSep "," members}";
  groupContents = (lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs groupToGroup groups)));

  defaultNixConf = {
    sandbox = "false";
    build-users-group = "nixbld";
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ]
    ++ extraTrustedPublicKeys;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://cache.nixos.org" ] ++ extraSubstituters;
  };

  nixConfContents =
    (lib.concatStringsSep "\n" (
      lib.attrsets.mapAttrsToList (
        n: v:
        let
          vStr = if builtins.isList v then lib.concatStringsSep " " v else v;
        in
        "${n} = ${vStr}"
      ) (defaultNixConf // nixConf)
    ))
    + "\n";
  userGroupIds = "${toString uid}:${toString gid}";

  baseSystem =
    let
      channel = pkgs.runCommand "channel-nixos" { inherit bundleNixpkgs; } ''
        mkdir $out
        if [ "$bundleNixpkgs" ]; then
          ln -s ${pkgs.path} $out/nixpkgs
          echo "[]" > $out/manifest.nix
        fi
      '';
      nix-channels = pkgs.writeTextFile {
        name = "nix-channels";
        text = ''
          ${lib.concatStringsSep "\n" (builtins.map (channel: "${channel.url} ${channel.name}") channelsList)}
        '';
      };
      rootEnv = pkgs.buildPackages.buildEnv {
        name = "root-profile-env";
        paths = defaultPkgs;
      };
      manifest = pkgs.buildPackages.runCommand "manifest.nix" { } ''
        cat > $out <<EOF
        [
        ${lib.concatStringsSep "\n" (
          builtins.map (
            drv:
            let
              outputs = drv.outputsToInstall or [ "out" ];
            in
            ''
              {
                ${lib.concatStringsSep "\n" (
                  builtins.map (output: ''
                    ${output} = { outPath = "${lib.getOutput output drv}"; };
                  '') outputs
                )}
                outputs = [ ${lib.concatStringsSep " " (builtins.map (x: "\"${x}\"") outputs)} ];
                name = "${drv.name}";
                outPath = "${drv}";
                system = "${drv.system}";
                type = "derivation";
                meta = { };
              }
            ''
          ) defaultPkgs
        )}
        ]
        EOF
      '';
      profile = pkgs.buildPackages.runCommand "user-environment" { } ''
        mkdir $out
        cp -a ${rootEnv}/* $out/
        ln -s ${manifest} $out/manifest.nix
      '';
      flake-registry-path =
        if (flake-registry == null) then
          null
        else if (builtins.readFileType (toString flake-registry)) == "directory" then
          "${flake-registry}/flake-registry.json"
        else
          flake-registry;
    in
    pkgs.runCommand "base-system"
      {
        inherit
          passwdContents
          groupContents
          shadowContents
          nixConfContents
          ;
        passAsFile = [
          "passwdContents"
          "groupContents"
          "shadowContents"
          "nixConfContents"
        ];
        allowSubstitutes = false;
        preferLocalBuild = true;
      }
      (
        ''
          env
          set -x
          mkdir -p $out/etc

          mkdir -p $out/etc/ssl/certs
          ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt $out/etc/ssl/certs
          ln -s /nix/var/nix/profiles $out/etc/profiles

          cat $passwdContentsPath > $out/etc/passwd
          echo "" >> $out/etc/passwd

          cat $groupContentsPath > $out/etc/group
          echo "" >> $out/etc/group

          cat $shadowContentsPath > $out/etc/shadow
          echo "" >> $out/etc/shadow

          mkdir -p $out/usr
          ln -s /nix/var/nix/profiles/share $out/usr/

          mkdir -p $out/nix/var/nix/gcroots

          mkdir $out/tmp

          mkdir -p $out/var/tmp

          mkdir -p $out/etc/nix
          cat $nixConfContentsPath > $out/etc/nix/nix.conf

          mkdir -p $out${userHome}
          mkdir -p $out/nix/var/nix/profiles/per-user/${uname}

          ln -s ${profile} $out/nix/var/nix/profiles/default-1-link
          ln -s $out/nix/var/nix/profiles/default-1-link $out/nix/var/nix/profiles/default
          ln -s /nix/var/nix/profiles/default $out${userHome}/.nix-profile

          ln -s ${channel} $out/nix/var/nix/profiles/per-user/${uname}/channels-1-link
          ln -s $out/nix/var/nix/profiles/per-user/${uname}/channels-1-link $out/nix/var/nix/profiles/per-user/${uname}/channels

          mkdir -p $out${userHome}/.nix-defexpr
          ln -s $out/nix/var/nix/profiles/per-user/${uname}/channels $out${userHome}/.nix-defexpr/channels
          ln -s ${nix-channels} $out${userHome}/.nix-channels

          mkdir -p $out/bin $out/usr/bin
          ln -s ${pkgs.coreutils}/bin/env $out/usr/bin/env
          ln -s ${pkgs.bashInteractive}/bin/bash $out/bin/sh

        ''
        + (lib.optionalString homeActivation ''
          rm $out${userHome}/.nix-profile
          ln -s /nix/var/nix/profiles/per-user/${uname} $out${userHome}/.nix-profile

          HOME_ACTIVATION=${nixpkgs.config.home-manager.users.${uname}.home.activationPackage}
          ls -al $HOME_ACTIVATION
          find $HOME_ACTIVATION/home-path/\
            -maxdepth 1 -type d | while read dir; do
            ln -s $dir $out/nix/var/nix/profiles/per-user/${uname}/$(basename $dir)
          done
          find $HOME_ACTIVATION/home-path/\
            -maxdepth 1 -type l | while read slink; do
            ln -s $slink $out/nix/var/nix/profiles/per-user/${uname}/$(basename $slink)
          done

          homeFiles="$HOME_ACTIVATION/home-files/"
          find "$homeFiles" -type d | while read dir; do
            relative=$(echo "$dir" | sed -e "s,^$homeFiles,,")
            dest=$out${userHome}/"$relative"
            if [ "$des" ]; then
              continue
            fi
            mkdir -p $dest
            find $dir -maxdepth 1 | while read file; do
              if [ ! -d $file ]; then
                ln -s $file $dest/$(basename $file)
              fi
            done
          done

        '')
        + (lib.optionalString (flake-registry-path != null) ''
          nixCacheDir="${userHome}/.cache/nix"
          mkdir -p $out$nixCacheDir
          globalFlakeRegistryPath="$nixCacheDir/flake-registry.json"
          ln -s ${flake-registry-path} $out$globalFlakeRegistryPath
          mkdir -p $out/nix/var/nix/gcroots/auto
          rootName=$(${pkgs.nix}/bin/nix --extra-experimental-features nix-command hash file --type sha1 --base32 ${flake-registry-path})
          ln -s $globalFlakeRegistryPath $out/nix/var/nix/gcroots/auto/$rootName
        '')
      );

in
pkgs.dockerTools.buildLayeredImageWithNixDb {

  inherit
    name
    tag
    maxLayers
    uid
    gid
    uname
    gname
    ;

  contents = [ baseSystem ];

  extraCommands = ''
    rm -rf nix-support
    ln -s /nix/var/nix/profiles nix/var/nix/gcroots/profiles
  '';
  fakeRootCommands = ''
    chmod 1777 tmp
    chmod 1777 var/tmp
    chown -R ${userGroupIds} .${userHome}
    chown -R ${userGroupIds} ./nix/var/nix/profiles/per-user/${uname}

    # copy config files
    ln -s ${./configuration.nix} ./etc/configuration.nix
  ''
  + (lib.optionalString etcActivation ''
    mv /nix/var/nix/profiles/per-user/{${uname},${uname}-tmp}
    ${nixpkgs.config.system.build.etcActivationCommands}
    mv /nix/var/nix/profiles/per-user/{${uname},root}
    mv /nix/var/nix/profiles/per-user/{${uname}-tmp,${uname}}
  '');

  enableFakechroot = true;
  created = "now";
  config = {
    Cmd = [ "${userHome}/.nix-profile/bin/bash" ];
    User = "${toString uid}:${toString gid}";
    Env = [
      "USER=${uname}"
      "PATH=${
        lib.concatStringsSep ":" [
          "${userHome}/.nix-profile/bin"
          "/nix/var/nix/profiles/default/bin"
          "/nix/var/nix/profiles/default/sbin"
        ]
      }"
      "MANPATH=${
        lib.concatStringsSep ":" [
          "${userHome}/.nix-profile/share/man"
          "/nix/var/nix/profiles/default/share/man"
        ]
      }"
      "SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      "NIX_PATH=/nix/var/nix/profiles/per-user/${uname}/channels:${userHome}/.nix-defexpr/channels"
    ];
  };

}
