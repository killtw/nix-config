{ ... }: {
  programs.starship = {
    enable = true;

    settings = {
      command_timeout = 10000;
      add_newline = true;

      aws = {
        disabled = true;
      };
      kubernetes = {
        disabled = false;
        detect_folders = [".helm"];
        detect_files = [
          "docker-compose.yml"
          "docker-compose.yaml"
          "Dockerfile"
          "helmfile.yaml"
        ];
      };
      gcloud = {
        disabled = true;
      };
    };
  };
}
