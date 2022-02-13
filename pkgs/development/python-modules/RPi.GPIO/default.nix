{ lib, stdenv, pythonAtLeast, pythonOlder, fetchPypi, python, buildPythonPackage
, setuptools, libcxx }:

buildPythonPackage rec {
  version = "0.7.1";
  pname = "RPi.GPIO";
  disabled = pythonOlder "3.6" || pythonAtLeast "3.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-zWHEsDw3tiu6SlrP6phidJwzxhjgKV5+kKpHE/s3O3A=";
  };

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";

  propagatedBuildInputs = [ setuptools ];

  doCheck = false;

  pythonImportsCheck = [ "RPi.GPIO" ];

  meta =  with lib; {
    homepage = "http://sourceforge.net/projects/raspberry-gpio-python/";
    license = licenses.mit;
    description = "Python module to control the GPIO on a Raspberry Pi.";
    maintainers = with maintainers; [ lunarequest ];
  };

}
