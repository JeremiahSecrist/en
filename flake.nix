{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
      checks."${system}".default = pkgs.nixosTest {
        name = "minmal-test";
        nodes.machine = ./configuration.nix;

        testScript = ''
          machine.wait_for_unit("default.target")
        '';
      };
    };
}
