{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "terminaltexteffects";
  version = "0.14.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ITyJnOS492Q9LQVorxROEnThHkST259bBDh70XwhdxQ=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  pythonImportsCheck = ["terminaltexteffects"];

  meta = with lib; {
    description = "A terminal visual effects engine";
    homepage = "https://github.com/ChrisBuilds/terminaltexteffects";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "tte";
  };
}
