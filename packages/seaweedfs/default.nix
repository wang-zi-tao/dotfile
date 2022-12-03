{ lib
, fetchFromGitHub
, buildGoModule
, testVersion
, seaweedfs
, buildGo118Module
}:
buildGo118Module rec {
  pname = "seaweedfs";
  version = "3.35";

  src = fetchFromGitHub {
    owner = "chrislusf";
    repo = "seaweedfs";
    rev = version;
    sha256 = "sha256-bcSm4WN4r8l488tGNkcsmfM1grc7Ii08qqV6IH39V9U=";
  };

  vendorSha256 = "sha256-fTQA3/G2HtOJGB0gSVIIrMnw0MQTTPp8eMyHMJIE5ns=";

  subPackages = [ "weed" ];

  passthru.tests.version =
    testVersion { package = seaweedfs; command = "weed version"; };

  meta = with lib; {
    description = "Simple and highly scalable distributed file system";
    homepage = "https://github.com/chrislusf/seaweedfs";
    mainProgram = "weed";
    license = licenses.asl20;
  };
}

