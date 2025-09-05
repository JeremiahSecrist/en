{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    stylix.url = "github:danth/stylix/release-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    with inputs;
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          # config._module.args = {inherit inputs;};
          inherit system;
          modules = [
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            { nixpkgs.config.allowUnfree = true; }
            ./configuration.nix
            ./packages.nix
          ];
        };
      };
    };
}
